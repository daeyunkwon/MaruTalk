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
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension ChannelAddReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

//MARK: - Reduce

extension ChannelAddReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
