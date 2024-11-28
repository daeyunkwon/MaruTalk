//
//  ChannelSettingReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import Foundation

import ReactorKit

final class ChannelSettingReactor: Reactor {
    enum Action {
        case fetch
        case arrowButtonTapped
        case editButtonTapped
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setChannel(Channel)
        case setExpand(Bool)
        case setNavigateToChannelEdit(Channel)
    }
    
    struct State {
        var channelID: String
        @Pulse var networkError: (Router.APIType, String?)?
        
        @Pulse var channel: Channel?
        var isExpand: Bool = true
        
        @Pulse var shouldNavigateToChannelEdit: Channel?
    }
    
    var initialState: State
    
    init(channelID: String) {
        self.initialState = State(channelID: channelID)
    }
}

//MARK: - Mutate

extension ChannelSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return fetchChannel()
            
        case .arrowButtonTapped:
            var newValue = currentState.isExpand
            newValue.toggle()
            return .just(.setExpand(newValue))
        
        case .editButtonTapped:
            guard let channel = currentState.channel else { return .empty() }
            return .just(.setNavigateToChannelEdit(channel))
        }
    }
}

//MARK: - Reduce

extension ChannelSettingReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setChannel(let value):
            newState.channel = value
        
        case .setExpand(let value):
            newState.isExpand = value
        
        case .setNavigateToChannelEdit(let value):
            newState.shouldNavigateToChannelEdit = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelSettingReactor {
    private func fetchChannel() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        
        return NetworkManager.shared.performRequest(api: .channel(workspaceID: workspaceID, channelID: channelID), model: Channel.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setChannel(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channel, error.errorCode)))
                }
            }
    }
}
