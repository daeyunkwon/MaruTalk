//
//  WorkspaceListReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/3/24.
//

import Foundation

import ReactorKit

final class WorkspaceListReactor: Reactor {
    enum Action {
        case fetch
        case createButtonTapped
        case shadowAreaTapped
        case selectWorkspace(Workspace)
        case selectWorkspaceExitActionSheet
        case selectWorkspaceChangeAdminActionSheet
        case selectWorkspaceDeleteActionSheet
        case selectRetryAction
        case selectRetryCancelAction
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setWorkspaceList([Workspace]?)
        case setNavigateToHome
        case setNavigateToWorkspaceAdd
        case setNavigateToWorkspaceChangeAdmin
        case setRetryDeleteChannelChatRealmDBAlert
        case setDeleteFailChannelIDList([String])
    }
    
    struct State {
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var workspaceList: [Workspace]?
        @Pulse var shouldnavigateToHome: Void?
        @Pulse var shouldNavigateToWorkspaceAdd: Void?
        @Pulse var shouldNavigateToWorkspaceChangeAdmin: Void?
        @Pulse var showRetryDeleteChannelChatRealmDBAlert: Void?
        var deleteFailChannelIDList: [String] = []
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension WorkspaceListReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return fetchWorkspaceList()
        
        case .createButtonTapped:
            return .just(.setNavigateToWorkspaceAdd)
            
        case .shadowAreaTapped:
            return .just(.setNavigateToHome)
        
        case .selectWorkspace(let value):
            //이미 선택된 워크스페이스를 또 선택한 경우
            if value.id == UserDefaultsManager.shared.recentWorkspaceID ?? "" {
                return .empty()
            }
            
            UserDefaultsManager.shared.recentWorkspaceID = value.id
            UserDefaultsManager.shared.recentWorkspaceOwnerID = value.ownerID
            NotificationCenter.default.post(name: .workspaceChangeComplete, object: nil)
            return .just(.setWorkspaceList(currentState.workspaceList))
        
        case .selectWorkspaceExitActionSheet:
            return executeWorkspaceExit()
        
        case .selectWorkspaceChangeAdminActionSheet:
            return .just(.setNavigateToWorkspaceChangeAdmin)
            
        case .selectWorkspaceDeleteActionSheet:
            return fetchChannelIDs() //채널 ID 먼저 조회 후 삭제까지 진행
        
        case .selectRetryAction:
            return deleteChannelChatFromRealmDB(channelIDs: currentState.deleteFailChannelIDList, shouldNavigateToHome: true)
        
        case .selectRetryCancelAction:
            NotificationCenter.default.post(name: .workspaceDeleteComplete, object: nil)
            return .just(.setNavigateToHome)
        }
    }
}

//MARK: - Reduce

extension WorkspaceListReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setWorkspaceList(let value):
            newState.workspaceList = value
            
        case .setNavigateToHome:
            newState.shouldnavigateToHome = ()
        
        case .setNavigateToWorkspaceAdd:
            newState.shouldNavigateToWorkspaceAdd = ()
        
        case .setNavigateToWorkspaceChangeAdmin:
            newState.shouldNavigateToWorkspaceChangeAdmin = ()
        
        case .setRetryDeleteChannelChatRealmDBAlert:
            newState.showRetryDeleteChannelChatRealmDBAlert = ()
        
        case .setDeleteFailChannelIDList(let value):
            newState.deleteFailChannelIDList = value
        }
        return newState
    }
}

//MARK: - Logic

extension WorkspaceListReactor {
    private func fetchWorkspaceList() -> Observable<Mutation> {
        return NetworkManager.shared.performRequest(api: .workspaces, model: [Workspace].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setWorkspaceList(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspace, error.errorCode)))
                }
            }
    }
    
    private func executeWorkspaceExit() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .workspaceExit(workspaceID: workspaceID), model: [Workspace].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    //워크스페이스 조회
                    return NetworkManager.shared.performRequest(api: .workspaces, model: [Workspace].self)
                        .asObservable()
                        .flatMap { result -> Observable<Mutation> in
                            switch result {
                            case .success(let value):
                                
                                if !value.isEmpty {
                                    //워크스페이스가 하나라도 있는 경우 최근 생성된 워크스페이스를 선택하기
                                    let sorted = value.sorted { $0.createdAt > $1.createdAt }
                                    UserDefaultsManager.shared.recentWorkspaceID = sorted.first?.id
                                    UserDefaultsManager.shared.recentWorkspaceOwnerID = sorted.first?.ownerID
                                    
                                } else {
                                    //워크스페이스가 없는 경우
                                    UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                                    UserDefaultsManager.shared.removeItem(key: .recentWorkspaceOwnerID)
                                }
                                
                                NotificationCenter.default.post(name: .workspaceExitComplete, object: nil)
                                return .just(.setNavigateToHome)
                                
                            case .failure(let error):
                                return .just(.setNetworkError((Router.APIType.workspaces, error.errorCode)))
                            }
                        }
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceExit, error.errorCode)))
                }
            }
    }
    
    //먼저 삭제할 워크스페이스에 포함된 채널 ID 모두 조회 (DB 데이터 제거를 위해 채널 ID 필요)
    private func fetchChannelIDs() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .channels(workspaceID: workspaceID), model: [Channel].self)
            .asObservable()
            .flatMap { [weak self] result -> Observable<Mutation> in
                guard let self else { return .empty() }
                switch result {
                case .success(let value):
                    let channelIDs = value.map { $0.id }
                    return self.executeWorkspaceDelete(workspaceID: workspaceID, channelIDs: channelIDs)
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channels, error.errorCode)))
                }
            }
    }
    
    private func executeWorkspaceDelete(workspaceID: String, channelIDs: [String]) -> Observable<Mutation> {
        return NetworkManager.shared.performDelete(api: .workspaceDelete(workspaceID: workspaceID))
            .asObservable()
            .flatMap { [weak self] result -> Observable<Mutation> in
                guard let self else { return .empty() }
                switch result {
                case .success():
                    //워크스페이스 조회
                    return NetworkManager.shared.performRequest(api: .workspaces, model: [Workspace].self)
                        .asObservable()
                        .flatMap { result -> Observable<Mutation> in
                            switch result {
                            case .success(let value):
                                
                                if !value.isEmpty {
                                    //워크스페이스가 하나라도 있는 경우 최근 생성된 워크스페이스를 선택하기
                                    let sorted = value.sorted { $0.createdAt > $1.createdAt }
                                    UserDefaultsManager.shared.recentWorkspaceID = sorted.first?.id
                                    UserDefaultsManager.shared.recentWorkspaceOwnerID = sorted.first?.ownerID
                                    
                                } else {
                                    //워크스페이스가 없는 경우
                                    UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                                    UserDefaultsManager.shared.removeItem(key: .recentWorkspaceOwnerID)
                                }
                                
                                return self.deleteChannelChatFromRealmDB(channelIDs: channelIDs, shouldNavigateToHome: true)
                                
                            case .failure(let error):
                                //삭제는 성공했지만 워크스페이스 조회 실패된 경우 DB 정리는 진행
                                return .concat([
                                    .just(.setNetworkError((Router.APIType.workspaces, error.errorCode))),
                                    self.deleteChannelChatFromRealmDB(channelIDs: channelIDs, shouldNavigateToHome: false)
                                ])
                            }
                        }
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceDelete, error.errorCode)))
                }
            }
    }
    
    private func deleteChannelChatFromRealmDB(channelIDs: [String], shouldNavigateToHome: Bool) -> Observable<Mutation> {
        let deleteObservables = channelIDs.map { channelID in
            Observable<String?>.create { observer in
                RealmChannelChatRepository.shared.deleteChatList(channelID: channelID) { isSuccess in
                    if isSuccess {
                        observer.onNext(nil)
                    } else {
                        observer.onNext(channelID)
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        }
        
        return Observable.zip(deleteObservables) // 모든 작업 병합
            .flatMap { [weak self] failIDs -> Observable<Mutation> in
                guard let self else { return .empty() }
                let resultFailIDs = failIDs.compactMap { $0 }
                
                if resultFailIDs.isEmpty {
                    //작업 실패된 채널 ID가 없는 경우
                    NotificationCenter.default.post(name: .workspaceDeleteComplete, object: nil)
                    if shouldNavigateToHome {
                        return .just(.setNavigateToHome)
                    } else {
                        //홈으로 가지 않고 다시 조회
                        return self.fetchWorkspaceList()
                    }
                    
                } else {
                    //작업 실패된 채널 ID가 있는 경우
                    return .concat([
                        .just(.setDeleteFailChannelIDList(resultFailIDs)),
                        .just(.setRetryDeleteChannelChatRealmDBAlert)
                    ])
                }
            }
    }
}
