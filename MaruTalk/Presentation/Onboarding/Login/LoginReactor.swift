//
//  LoginReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/19/24.
//

import Foundation

import ReactorKit

final class LoginReactor: Reactor {
    enum Action {
        case xButtonTapped
    }
    
    enum Mutation {
        case setNavigateToAuth(Bool)
        case setNavigateToHome(Bool)
    }
    
    struct State {
        var shouldNavigateToAuth = false
        var shouldNavigateToHome = false
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension LoginReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xButtonTapped:
            return .just(.setNavigateToAuth(true))
        }
    }
}

//MARK: - Reduce

extension LoginReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToAuth(let value):
            newState.shouldNavigateToAuth = value
        
        case .setNavigateToHome(let value):
            newState.shouldNavigateToHome = value
        }
        return newState
    }
}
