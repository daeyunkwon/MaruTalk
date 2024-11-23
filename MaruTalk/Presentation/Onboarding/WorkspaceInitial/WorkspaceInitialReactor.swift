//
//  WorkspaceInitialReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/11/24.
//

import Foundation

import ReactorKit

final class WorkspaceInitialReactor: Reactor {
    enum Action {
        case createWorkspaceButtonTapped
        case xButtonTapped
    }
    
    enum Mutation {
        case setNavigateToWorkspaceAdd(Bool)
        case setNavigateToHome(Bool)
    }
    
    struct State {
        var nickname = ""
        var shouldNavigateToWorkspaceAdd = false
        var shouldNavigateToHome = false
    }
    
    let initialState: State
    
    init(nickname: String) {
        self.initialState = State(nickname: nickname)
    }
}

//MARK: - Mutate

extension WorkspaceInitialReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .createWorkspaceButtonTapped:
            return .just(.setNavigateToWorkspaceAdd(true))
            
        case .xButtonTapped:
            return .concat([
                NetworkManager.shared.performRequest(api: .workspaces, model: [WorkspaceList].self)
                    .asObservable()
                    .flatMap { result -> Observable<Mutation> in
                        switch result {
                        case .success(let value):
                            print("통신값:", value)
                            if !value.isEmpty {
                                let sortedValue = value.sorted {
                                    $0.createdDate > $1.createdDate
                                }
                                UserDefaultsManager.shared.recentWorkspaceID = sortedValue.first?.id
                                UserDefaultsManager.shared.recentWorkspaceOwnerID = sortedValue.first?.ownerID
                            } else {
                                UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                                UserDefaultsManager.shared.removeItem(key: .recentWorkspaceOwnerID)
                            }
                            
                            return .just(.setNavigateToHome(true))
                        
                        case .failure(_):
                            UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                            return .just(.setNavigateToHome(true))
                        }
                    }
            ])
        }
    }
}

//MARK: - Reduce

extension WorkspaceInitialReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNavigateToWorkspaceAdd(let value):
            newState.shouldNavigateToWorkspaceAdd = value
            
        case .setNavigateToHome(let value):
            newState.shouldNavigateToHome = value
        }
        return newState
    }
}
