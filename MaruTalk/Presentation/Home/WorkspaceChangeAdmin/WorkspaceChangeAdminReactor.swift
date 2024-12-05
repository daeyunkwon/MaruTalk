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
    }
    
    enum Mutation {
        case setMemberList([User])
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        @Pulse var memberList: [User]?
        @Pulse var networkError: (Router.APIType, String?)?
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension WorkspaceChangeAdminReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return .empty()
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
        }
        return newState
    }
}

