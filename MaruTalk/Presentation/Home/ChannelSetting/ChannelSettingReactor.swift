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
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setChannelName(String)
        case setDescription(String)
        case setMemberCount(Int)
        case setMemberList([User])
        case setExpand(Bool)
    }
    
    struct State {
        var channelID: String
        @Pulse var networkError: (Router.APIType, String?)?
        
        var channelName: String = ""
        var description: String = ""
        var memberCount: Int = 0
        @Pulse var memberList: [User]?
        var isExpand: Bool = true
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
        
        case .setChannelName(let value):
            newState.channelName = value
        
        case .setDescription(let value):
            newState.description = value
        
        case .setMemberCount(let value):
            newState.memberCount = value
        
        case .setMemberList(let value):
            newState.memberList = value
        
        case .setExpand(let value):
            newState.isExpand = value
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
                    return .concat([
                        .just(.setChannelName(value.name)),
                        .just(.setDescription(value.description ?? "")),
                        .just(.setMemberCount(value.channelMembers?.count ?? 0)),
                        .just(.setMemberList(value.channelMembers ?? []))
                    ])
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channel, error.errorCode)))
                }
            }
    }
}
