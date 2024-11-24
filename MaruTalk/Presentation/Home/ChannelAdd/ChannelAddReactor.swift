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
        case createButtonTapped
    }
    
    enum Mutation {
        case setDismiss(())
        case setChannelName(String)
        case setChannelDescription(String)
        case setCreateButtonEnabled(Bool)
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        @Pulse var shouldDismiss: Void?
        var channelName = ""
        var channelDescription: String?
        var isCreateButtonEnabled = false
        @Pulse var networkError: (Router.APIType, String?)?
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
            
        case .createButtonTapped:
            return createChannel()
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
            newState.channelDescription = value
        
        case .setCreateButtonEnabled(let value):
            newState.isCreateButtonEnabled = value
        
        case .setNetworkError(let value):
            newState.networkError = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelAddReactor {
    private func isChannelNameValid(name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty ? true : false
    }
    
    //채널 생성 요청
    private func createChannel() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelName = currentState.channelName
        let description = currentState.channelDescription
        
        return NetworkManager.shared.performRequestMultipartFormData(api: .createChannel(workspaceID: workspaceID, name: channelName, description: description, imageData: nil), model: Channel.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    print("채널생성--------------------------")
                    print(value)
                    print("--------------------------------")
                    NotificationCenter.default.post(name: .channelAddComplete, object: nil)
                    return .just(.setDismiss(()))
                
                case .failure(let error):
                    let errorCode = error.errorCode
                    return .just(.setNetworkError((Router.APIType.createChannel, errorCode)))
                }
            }
    }
}
