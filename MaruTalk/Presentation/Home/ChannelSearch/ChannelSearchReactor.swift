//
//  ChannelSearchReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import Foundation

import ReactorKit

final class ChannelSearchReactor: Reactor {
    enum Action {
        case xMarkButtonTapped
        case fetch
        case selectChannel(Channel)
    }
    
    enum Mutation {
        case setNavigateToHome
        case setNetworkError((Router.APIType, String?))
        case setChannelList([Channel])
        case setMyChannelDictionary([String: Bool])
        case setShowJoinAlert(Channel)
        case setNavigateToCannelChatting(Channel)
    }
    
    struct State {
        @Pulse var navigateToHome: Void?
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var channelList: [Channel]?
        var myChannelDictionary: [String: Bool] = [:]
        @Pulse var showJoinAlert: Channel?
        @Pulse var navigateToCannelChatting: Channel?
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension ChannelSearchReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xMarkButtonTapped:
            return .just(.setNavigateToHome)
        
        case .fetch:
            return .concat([
                fetchMyChannels(),
                fetchAllChannels()
            ])
        
        case .selectChannel(let value):
            if let _ = currentState.myChannelDictionary[value.id] {
                //이미 참여중인 채널인 경우
                return .just(.setNavigateToCannelChatting(value))
            } else {
                //미참여 채널인 경우
                return .just(.setShowJoinAlert(value))
            }
        }
    }
}

//MARK: - Reduce

extension ChannelSearchReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToHome:
            newState.navigateToHome = ()
            
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setChannelList(let value):
            newState.channelList = value
        
        case .setMyChannelDictionary(let value):
            newState.myChannelDictionary = value
        
        case .setShowJoinAlert(let value):
            newState.showJoinAlert = value
        
        case .setNavigateToCannelChatting(let value):
            newState.navigateToCannelChatting = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelSearchReactor {
    private func fetchAllChannels() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        return NetworkManager.shared.performRequest(api: .channels(workspaceID: workspaceID), model: [Channel].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setChannelList(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channels, error.errorCode)))
                }
            }
    }
    
    private func fetchMyChannels() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        return NetworkManager.shared.performRequest(api: .myChannels(workspaceID: workspaceID), model: [Channel].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    let myChannelIDDictionary = Dictionary(uniqueKeysWithValues: value.map { ($0.id, true) })
                    return .just(.setMyChannelDictionary(myChannelIDDictionary))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channels, error.errorCode)))
                }
            }
    }
}
