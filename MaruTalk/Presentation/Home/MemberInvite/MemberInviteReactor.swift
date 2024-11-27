//
//  MemberInviteReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import Foundation

import ReactorKit

final class MemberInviteReactor: Reactor {
    enum Action {
        case inputEmail(String)
    }
    
    enum Mutation {
        case setEmail(String)
        case setInviteButtonEnabled(Bool)
    }
    
    struct State {
        var email: String = ""
        var isInviteButtonEnabled = false
    }
    
    var initialState: State = State()
}

//MARK: - Mutate

extension MemberInviteReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputEmail(let value):
            let isValid = !value.trimmingCharacters(in: .whitespaces).isEmpty ? true : false
            return .concat([
                .just(.setEmail(value)),
                .just(.setInviteButtonEnabled(isValid))
            ])
        }
    }
}

//MARK: - Reduce

extension MemberInviteReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setEmail(let value):
            newState.email = value
        
        case .setInviteButtonEnabled(let value):
            newState.isInviteButtonEnabled = value
        }
        return newState
    }
}
