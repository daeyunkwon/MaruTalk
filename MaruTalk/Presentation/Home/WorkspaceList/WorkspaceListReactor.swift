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
        case selectWorkspaceExit
        case selectWorkspaceChangeAdmin
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setWorkspaceList([Workspace]?)
        case setNavigateToHome
        case setNavigateToWorkspaceAdd
        case setNavigateToWorkspaceChangeAdmin
    }
    
    struct State {
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var workspaceList: [Workspace]?
        @Pulse var shouldnavigateToHome: Void?
        @Pulse var shouldNavigateToWorkspaceAdd: Void?
        @Pulse var shouldNavigateToWorkspaceChangeAdmin: Void?
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
        
        case .selectWorkspaceExit:
            return executeWorkspaceExit()
        
        case .selectWorkspaceChangeAdmin:
            return .just(.setNavigateToWorkspaceChangeAdmin)
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
}
