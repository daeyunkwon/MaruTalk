//
//  WorkspaceChangeAdminReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/5/24.
//

import Foundation

import ReactorKit

final class WorkspaceChangeAdminReactor: Reactor {
    enum Action {
        case fetch
        case xMarkButtonTapped
        case selectChangeAdmin(User)
    }
    
    enum Mutation {
        case setMemberList([User])
        case setNetworkError((Router.APIType, String?))
        case setNavigateToWorkspaceList
    }
    
    struct State {
        @Pulse var memberList: [User]?
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var navigateToWorkspaceList: Void?
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension WorkspaceChangeAdminReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return fetchMembers()
        
        case .xMarkButtonTapped:
            return .just(.setNavigateToWorkspaceList)
        
        case .selectChangeAdmin(let value):
            return executeTransferOwnership(userID: value.userID)
        }
    }
}

//MARK: - Reduce

extension WorkspaceChangeAdminReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMemberList(let value):
            newState.memberList = value
            
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setNavigateToWorkspaceList:
            newState.navigateToWorkspaceList = ()
        }
        return newState
    }
}

//MARK: - Logic

extension WorkspaceChangeAdminReactor {
    private func fetchMembers() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .workspaceMembers(workspaceID: workspaceID), model: [User].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    let filtered = value.filter { $0.userID != UserDefaultsManager.shared.userID ?? "" }
                    return .just(.setMemberList(filtered))
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceMembers, error.errorCode)))
                }
            }
    }
    
    private func executeTransferOwnership(userID: String) -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .workspaceTransferOwnership(workspaceID: workspaceID, userID: userID), model: Workspace.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    UserDefaultsManager.shared.recentWorkspaceOwnerID = userID
                    NotificationCenter.default.post(name: .workspaceChangeAdminComplete, object: nil)
                    return .just(.setNavigateToWorkspaceList)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceTransferOwnership, error.errorCode)))
                }
            }
    }
}
