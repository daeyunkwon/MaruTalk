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
        case inputName(String)
        case inputDescription(String)
    }
    
    enum Mutation {
        case setDismiss(())
        case setChannelName(String)
        case setChannelDescription(String)
        case setCreateButtonEnabled(Bool)
    }
    
    struct State {
        @Pulse var shouldDismiss: Void?
        var channelName = ""
        var chaanelDescription = ""
        var isCreateButtonEnabled = false
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension ChannelAddReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setDismiss(()))
            
        case .inputName(let value):
            let isValid = isChannelNameValid(name: value)
            
            return .concat([
                .just(.setChannelName(value)),
                .just(.setCreateButtonEnabled(isValid))
            ])
            
        case .inputDescription(let value):
            return .just(.setChannelDescription(value))
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
        
        case .setChannelName(let value):
            newState.channelName = value
        
        case .setChannelDescription(let value):
            newState.chaanelDescription = value
        
        case .setCreateButtonEnabled(let value):
            newState.isCreateButtonEnabled = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelAddReactor {
    private func isChannelNameValid(name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty ? true : false
    }
}
