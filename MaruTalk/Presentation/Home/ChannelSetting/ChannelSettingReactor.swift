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
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setChannel(Channel)
        case setExpand(Bool)
        case setNavigateToChannelEdit(Channel)
        case setNavigateToChannelChangeAdmin(String)
        case setNavigateToHome(Void)
    }
    
    struct State {
        var channelID: String
        @Pulse var networkError: (Router.APIType, String?)?
        
        @Pulse var channel: Channel?
        var isExpand: Bool = true
        
        @Pulse var shouldNavigateToChannelEdit: Channel?
        @Pulse var shouldNavigateToChannelChangeAdmin: String?
        @Pulse var shouldNaviageToHome: Void?
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
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setChannel(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channel, error.errorCode)))
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
                    //DB에서 관련 채팅 데이터 삭제 진행
                    return Observable.create { [weak self] observer in
                        guard let self else { return Disposables.create() }
                        
                        let compositeDisposable = CompositeDisposable()
                        
                        RealmRepository.shared.deleteChatList(channelID: channelID) { isSuccess in
                            if isSuccess {
                                //성공
                                observer.onNext(.setNavigateToHome(()))
                            } else {
                                //실패
                                print("ERROR: 채널 나가기로 인해 Realm에서 관련 채널 모든 채팅 삭제 실패")
                                //다시 채널 가입 처리
                                let fallbackDisposable = NetworkManager.shared
                                    .performRequest(api: .chats(workspaceID: workspaceID, channelID: channelID, cursorDate: nil), model: [Chat].self)
                                    .asObservable()
                                    .subscribe(onNext: { result in
                                        switch result {
                                        case .success(_):
                                            print("DEBUG: 재 가입 성공")
                                            //채널 나가기는 취소된 상태, 우선 에러 보내기
                                            observer.onNext(.setNetworkError((Router.APIType.channelExit, nil)))
                                            
                                        case .failure(let error):
                                            print("Error: 재 가입 실패: \(error)")
                                            observer.onNext(.setNetworkError((Router.APIType.channelExit, nil)))
                                        }
                                        
                                    }, onError: { error in
                                        print("Error: 재 가입 실패: \(error)")
                                        //재가입 마저 실패 시 우선 채널 나가기는 처리되었으므로 홈 화면 전환
                                        observer.onNext(.setNavigateToHome(()))
                                    })
                                
                               let _ = compositeDisposable.insert(fallbackDisposable)
                            }
                            observer.onCompleted()
                        }
                        return Disposables.create {
                            compositeDisposable.dispose()
                        }
                    }
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channelExit, error.errorCode)))
                }
            }
    }
}
