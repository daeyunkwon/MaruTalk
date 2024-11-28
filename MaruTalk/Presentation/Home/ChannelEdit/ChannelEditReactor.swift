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
    }
    
    enum Mutation {
        case setNavigateToChannelSetting
    }
    
    struct State {
        var channel: Channel
        @Pulse var shouldNavigateToChannelSetting: Void?
    }
    
    var initialState: State
    
    init(channel: Channel) {
        self.initialState = State(channel: channel)
    }
}

//MARK: - Mutate

extension ChannelEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setNavigateToChannelSetting)
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
        }
        return newState
    }
}
