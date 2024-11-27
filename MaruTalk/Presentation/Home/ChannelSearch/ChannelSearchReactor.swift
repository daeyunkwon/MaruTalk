//
//  ChannelSearchReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import Foundation

import ReactorKit

final class ChannelSearchReactor: Reactor {
    enum Action {
        case xMarkButtonTapped
    }
    
    enum Mutation {
        case setNavigateToHome
    }
    
    struct State {
        @Pulse var shouldNavigateToHome: Void?
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension ChannelSearchReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setNavigateToHome)
        }
    }
}

//MARK: - Reduce

extension ChannelSearchReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToHome:
            newState.shouldNavigateToHome = ()
        }
        return newState
    }
}
