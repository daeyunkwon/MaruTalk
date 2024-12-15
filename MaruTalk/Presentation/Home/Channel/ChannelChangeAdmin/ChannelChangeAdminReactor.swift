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
        case fetch
        case selectRow(Int)
    }
    
    enum Mutation {
        case setNavigateToChannelSetting
        case setNetworkError((Router.APIType, String?))
        case setMemberList([User])
    }
    
    struct State {
        var channelID: String
        @Pulse var navigateToChannelSetting: Void?
        @Pulse var networkError: (Router.APIType, String?)?
        
        @Pulse var memberList: [User]?
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
        
        case .fetch:
            return fetchMembers()
        
        case .selectRow(let value):
            guard let selectMemberID = currentState.memberList?[value] else { return .empty() }
            return executeChangeAdmin(memberID: selectMemberID.userID)
        }
    }
}

//MARK: - Reduce

extension ChannelChangeAdminReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToChannelSetting:
            newState.navigateToChannelSetting = ()
        
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setMemberList(let value):
            newState.memberList = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelChangeAdminReactor {
    private func fetchMembers() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        return NetworkManager.shared.performRequest(api: .channelMembers(workspaceID: workspaceID, channelID: channelID), model: [User].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    let loginUser = UserDefaultsManager.shared.userID ?? ""
                    let filteredMembers = value.filter { $0.userID != loginUser}
                    return .just(.setMemberList(filteredMembers))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channelMembers, error.errorCode)))
                }
            }
    }
    
    private func executeChangeAdmin(memberID: String) -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let channelID = currentState.channelID
        
        return NetworkManager.shared.performRequest(api: .channelChangeAdmin(workspaceID: workspaceID, channelID: channelID, memberID: memberID), model: Channel.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: .channelChangeAdminComplete, object: nil)
                    return .just(.setNavigateToChannelSetting)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channelChangeAdmin, error.errorCode)))
                }
            }
    }
}
