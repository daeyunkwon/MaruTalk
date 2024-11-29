//
//  ChannelEditReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import Foundation

import ReactorKit

final class ChannelEditReactor: Reactor {
    enum Action {
        case xMarkButtonTapped
        case inputName(String)
        case inputDescription(String?)
    }
    
    enum Mutation {
        case setNavigateToChannelSetting
        case setChannelName(String)
        case setChannelDescription(String?)
        case setDoneButtonEnabled(Bool)
    }
    
    struct State {
        @Pulse var shouldNavigateToChannelSetting: Void?
        var channelName: String
        var channelDescription: String?
        var isDoneButtonEnabled: Bool = true
    }
    
    var initialState: State
    
    init(channel: Channel) {
        self.initialState = State(channelName: channel.name, channelDescription: channel.description)
    }
}

//MARK: - Mutate

extension ChannelEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setNavigateToChannelSetting)
        
        case .inputName(let value):
            let isValid: Bool = !value.trimmingCharacters(in: .whitespaces).isEmpty ? true : false
            
            return .concat([
                .just(.setChannelName(value)),
                .just(.setDoneButtonEnabled(isValid))
            ])
            
        case .inputDescription(let value):
            return .just(.setChannelDescription(value))
        }
    }
}

//MARK: - Reduce

extension ChannelEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToChannelSetting:
            newState.shouldNavigateToChannelSetting = ()
        
        case .setChannelName(let value):
            newState.channelName = value
        
        case .setChannelDescription(let value):
            newState.channelDescription = value
        
        case .setDoneButtonEnabled(let value):
            newState.isDoneButtonEnabled = value
        }
        return newState
    }
}
