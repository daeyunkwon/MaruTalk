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
        case selectWorkspace(Workspace)
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setWorkspaceList([Workspace]?)
        case setNavigateToWorkspaceAdd
    }
    
    struct State {
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var workspaceList: [Workspace]?
        @Pulse var shouldNavigateToWorkspaceAdd: Void?
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
        
        case .selectWorkspace(let value):
            UserDefaultsManager.shared.recentWorkspaceID = value.id
            UserDefaultsManager.shared.recentWorkspaceOwnerID = value.ownerID
            NotificationCenter.default.post(name: .workspaceChangeComplete, object: nil)
            return .just(.setWorkspaceList(currentState.workspaceList))
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
        
        case .setNavigateToWorkspaceAdd:
            newState.shouldNavigateToWorkspaceAdd = ()
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
}
