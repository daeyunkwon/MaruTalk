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
        case doneButtonTapped
    }
    
    enum Mutation {
        case setNavigateToChannelSetting
        case setChannelName(String)
        case setChannelDescription(String?)
        case setDoneButtonEnabled(Bool)
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        @Pulse var shouldNavigateToChannelSetting: Void?
        var channelID: String
        var channelName: String
        var channelDescription: String?
        var isDoneButtonEnabled: Bool = true
        @Pulse var networkError: (Router.APIType, String?)?
    }
    
    var initialState: State
    
    init(channel: Channel) {
        self.initialState = State(
            channelID: channel.id,
            channelName: channel.name,
            channelDescription: channel.description
        )
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
        
        case .doneButtonTapped:
            return executeChannelEdit()
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
        
        case .setNetworkError(let value):
            newState.networkError = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelEditReactor {
    private func executeChannelEdit() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        let name = currentState.channelName
        let description = currentState.channelDescription
        
        return NetworkManager.shared.performRequestMultipartFormData(api: .channelEdit(workspaceID: workspaceID, channelID: channelID, name: name, description: description), model: Channel.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    print("DEBUG: 채널 편집 성공")
                    NotificationCenter.default.post(name: .channelEditComplete, object: nil)
                    return .just(.setNavigateToChannelSetting)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channelEdit, error.errorCode)))
                }
            }
    }
}
