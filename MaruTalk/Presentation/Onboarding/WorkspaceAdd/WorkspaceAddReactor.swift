//
//  WorkspaceAddReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/12/24.
//

import Foundation

import ReactorKit

final class WorkspaceAddReactor: Reactor {
    enum Action {
        case inputName(String)
        case inputDescription(String)
    }
    
    enum Mutation {
        case setName(String)
        case setDescription(String)
        case setDoneButtonEnabled(Bool)
    }
    
    struct State {
        var name = ""
        var description = ""
        
        var isDoneButtonEnabled = false
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension WorkspaceAddReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputName(let value):
            let isEnabled = isDoneButtonEnabled(name: value)
            
            return .concat([
                .just(.setName(value)),
                .just(.setDoneButtonEnabled(isEnabled))
            ])
        
        case .inputDescription(let value):
            
            return .concat([
                .just(.setDescription(value)),
            ])
        }
    }
}

//MARK: - Reduce

extension WorkspaceAddReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setName(let value):
            newState.name = value
        
        case .setDescription(let value):
            newState.description = value
            
        case .setDoneButtonEnabled(let value):
            newState.isDoneButtonEnabled = value
        }
        return newState
    }
}

//MARK: - Logic

extension WorkspaceAddReactor {
    func isDoneButtonEnabled(name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
