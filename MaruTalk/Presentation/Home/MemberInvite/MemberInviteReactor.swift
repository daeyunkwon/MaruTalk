//
//  MemberInviteReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import Foundation

import ReactorKit

final class MemberInviteReactor: Reactor {
    enum Action {
        case inputEmail(String)
        case xMarkButtonTapped
        case inviteButtonTapped
    }
    
    enum Mutation {
        case setEmail(String)
        case setInviteButtonEnabled(Bool)
        case setNavigateToHome(Bool)
        case setInviteSuccess(Bool)
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        var email: String = ""
        var isInviteButtonEnabled = false
        var navigateToHome = false
        var inviteSuccess: Bool = false
        @Pulse var networkError: (Router.APIType, String?)?
    }
    
    var initialState: State = State()
}

//MARK: - Mutate

extension MemberInviteReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputEmail(let value):
            let isValid = !value.trimmingCharacters(in: .whitespaces).isEmpty ? true : false
            return .concat([
                .just(.setEmail(value)),
                .just(.setInviteButtonEnabled(isValid))
            ])
        
        case .xMarkButtonTapped:
            return .just(.setNavigateToHome(true))
        
        case .inviteButtonTapped:
            return executeInviteMember()
        }
    }
}

//MARK: - Reduce

extension MemberInviteReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setEmail(let value):
            newState.email = value
        
        case .setInviteButtonEnabled(let value):
            newState.isInviteButtonEnabled = value
        
        case .setNavigateToHome(let value):
            newState.navigateToHome = value
        
        case .setInviteSuccess(let value):
            newState.inviteSuccess = value
        
        case .setNetworkError(let value):
            newState.networkError = value
        }
        return newState
    }
}


//MARK: - Logic

extension MemberInviteReactor {
    private func executeInviteMember() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let email = currentState.email
        
        return NetworkManager.shared.performRequest(api: .workspaceMemberInvite(workspaceID: workspaceID, email: email), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    return .just(.setInviteSuccess(true))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceMemberInvite, error.errorCode)))
                }
            }
    }
}
