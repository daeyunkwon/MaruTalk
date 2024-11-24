//
//  ChannelAddReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/23/24.
//

import Foundation

import ReactorKit

final class ChannelAddReactor: Reactor {
    enum Action {
        case xMarkButtonTapped
    }
    
    enum Mutation {
        case setDismiss(())
    }
    
    struct State {
        @Pulse var shouldDismiss: Void?
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension ChannelAddReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setDismiss(()))
        }
    }
}

//MARK: - Reduce

extension ChannelAddReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDismiss(let value):
            newState.shouldDismiss = value
        }
        return newState
    }
}
