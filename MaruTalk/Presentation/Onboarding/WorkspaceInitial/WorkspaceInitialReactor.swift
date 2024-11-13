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
    }
    
    enum Mutation {
        case setNavigateToWorkspaceAdd(Bool)
    }
    
    struct State {
        var nickname = ""
        var shouldNavigateToWorkspaceAdd = false
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
        }
        return newState
    }
}
