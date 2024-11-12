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
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var nickname = ""
    }
    
    let initialState: State
    
    init(nickname: String) {
        self.initialState = State(nickname: nickname)
    }
}

//MARK: - Mutate

extension WorkspaceInitialReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

//MARK: - Reduce

extension WorkspaceInitialReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
