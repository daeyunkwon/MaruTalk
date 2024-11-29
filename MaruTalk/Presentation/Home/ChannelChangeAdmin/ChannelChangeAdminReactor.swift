//
//  ChannelChangeAdminReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/29/24.
//

import Foundation

import ReactorKit

final class ChannelChangeAdminReactor: Reactor {
    enum Action {
        case xMarkButtonTapped
    }
    
    enum Mutation {
        case setNavigateToChannelSetting
    }
    
    struct State {
        var channelID: String
        @Pulse var shouldNavigateToChannelSetting: Void?
    }
    
    var initialState: State
    
    init(channelID: String) {
        self.initialState = State(channelID: channelID)
    }
}

//MARK: - Mutate

extension ChannelChangeAdminReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setNavigateToChannelSetting)
        }
    }
}

//MARK: - Reduce

extension ChannelChangeAdminReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToChannelSetting:
            newState.shouldNavigateToChannelSetting = ()
        }
        return newState
    }
}
