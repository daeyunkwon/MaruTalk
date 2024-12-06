//
//  ChannelSettingReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import Foundation

import ReactorKit

final class ChannelSettingReactor: Reactor {
    enum Action {
        case fetch
        case arrowButtonTapped
        case editButtonTapped
        case changeAdminButtonTapped
        case exitTapped
        case deleteTapped
        case retryDeleteFromDB //재시도 얼럿에서 재시도 선택
        case cancelRetryDeleteFromDB //재시도 얼럿에서 취소 선택
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setChannel(Channel)
        case setExpand(Bool)
        case setNavigateToChannelEdit(Channel)
        case setNavigateToChannelChangeAdmin(String)
        case setNavigateToHome(Void)
        case setShowRetryDeleteFromDBAlert
    }
    
    struct State {
        var channelID: String
        @Pulse var networkError: (Router.APIType, String?)?
        
        @Pulse var channel: Channel?
        var isExpand: Bool = true
        
        @Pulse var shouldNavigateToChannelEdit: Channel?
        @Pulse var shouldNavigateToChannelChangeAdmin: String?
        @Pulse var shouldNaviageToHome: Void?
        @Pulse var shouldShowRetryDeleteFromDBAlert: Void?
    }
    
    var initialState: State
    
    private let disposeBag = DisposeBag()
    
    init(channelID: String) {
        self.initialState = State(channelID: channelID)
    }
}

//MARK: - Mutate

extension ChannelSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return fetchChannel()
            
        case .arrowButtonTapped:
            var newValue = currentState.isExpand
            newValue.toggle()
            return .just(.setExpand(newValue))
        
        case .editButtonTapped:
            guard let channel = currentState.channel else { return .empty() }
            return .just(.setNavigateToChannelEdit(channel))
        
        case .changeAdminButtonTapped:
            let channelID = currentState.channelID
            return .just(.setNavigateToChannelChangeAdmin(channelID))
        
        case .exitTapped:
            return executeChannelExit()
        
        case .deleteTapped:
            return executeChannelDelete()
        
        case .retryDeleteFromDB:
            let channelID = currentState.channelID
            return deleteChatListFromRealmDB(channelID: channelID)
                .map { isSuccess -> Mutation in
                    if isSuccess {
                        return .setNavigateToHome(())
                    } else {
                        return .setShowRetryDeleteFromDBAlert
                    }
                }
        
        case .cancelRetryDeleteFromDB:
            return .just(.setNavigateToHome(()))
        }
    }
}

//MARK: - Reduce

extension ChannelSettingReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setChannel(let value):
            newState.channel = value
        
        case .setExpand(let value):
            newState.isExpand = value
        
        case .setNavigateToChannelEdit(let value):
            newState.shouldNavigateToChannelEdit = value
            
        case .setNavigateToChannelChangeAdmin(let value):
            newState.shouldNavigateToChannelChangeAdmin = value
        
        case .setNavigateToHome():
            newState.shouldNaviageToHome = ()
        
        case .setShowRetryDeleteFromDBAlert:
            newState.shouldShowRetryDeleteFromDBAlert = ()
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelSettingReactor {
    private func fetchChannel() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        
        return NetworkManager.shared.performRequest(api: .channel(workspaceID: workspaceID, channelID: channelID), model: Channel.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let value):
                    return .setChannel(value)
                
                case .failure(let error):
                    return .setNetworkError((Router.APIType.channel, error.errorCode))
                }
            }
    }
    
    private func executeChannelExit() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        
        return NetworkManager.shared.performRequest(api: .channelExit(workspaceID: workspaceID, channelID: channelID), model: [Channel].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    // Realm 작업 클로저 처리
                    return self.deleteChatListFromRealmDB(channelID: channelID)
                        .flatMap { isSuccess -> Observable<Mutation> in
                            if isSuccess {
                                return .just(.setNavigateToHome(()))
                            } else {
                                print("ERROR: 채널 나가기로 인해 Realm에서 관련 채널 모든 채팅 삭제 실패")
                                // 채널 재가입 처리
                                return NetworkManager.shared.performRequest(api: .chats(workspaceID: workspaceID, channelID: channelID, cursorDate: nil), model: [Chat].self)
                                    .asObservable()
                                    .map { result -> Mutation in
                                        switch result {
                                        case .success(_):
                                            print("DEBUG: 재 가입 성공")
                                            //채널 나가기는 취소 및 재가입한 상태, 우선 에러 보내기(사용자가 다시 나가기 시도하도록 유도)
                                            return .setNetworkError((Router.APIType.channelExit, nil))
                                        case .failure(let error):
                                            print("Error: 재 가입 실패: \(error)")
                                            //재가입 마저 실패된 경우, 우선 채널 나가기는 처리되었으므로 홈 화면 전환
                                            return .setNavigateToHome(())
                                        }
                                    }
                            }
                        }
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channelExit, error.errorCode)))
                }
            }
    }

    //Realm 삭제 작업 처리 메서드
    private func deleteChatListFromRealmDB(channelID: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            RealmChannelChatRepository.shared.deleteChatList(channelID: channelID) { isSuccess in
                observer.onNext(isSuccess)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    
    private func executeChannelDelete() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        
        return NetworkManager.shared.deleteChannel(workspaceID: workspaceID, channelID: channelID)
            .asObservable()
            .flatMap { [weak self] result -> Observable<Mutation> in
                guard let self else { return .empty() }
                switch result {
                case .success():
                    return deleteChatListFromRealmDB(channelID: channelID)
                        .map { isSuccess -> Mutation in
                            if isSuccess {
                                return .setNavigateToHome(())
                            } else {
                                return .setShowRetryDeleteFromDBAlert
                            }
                        }
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channelDelete, error.errorCode)))
                }
            }
    }
}
