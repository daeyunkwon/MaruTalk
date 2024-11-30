//
//  DMListReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import Foundation

import ReactorKit

final class DMListReactor: Reactor {
    enum Action {
        case fetch
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setMemberList([User])
    }
    
    struct State {
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var memberList: [User]?
    }
    
    var initialState: State = State()
}

//MARK: - Mutate

extension DMListReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return fetchMemberList()
        }
    }
}

//MARK: - Reduce

extension DMListReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setMemberList(let value):
            newState.memberList = value
        }
        return newState
    }
}

//MARK: - Logic

extension DMListReactor {
    //멤버 리스트 조회
    private func fetchMemberList() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .workspaceMembers(workspaceID: workspaceID), model: [User].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    let filteredList = value.filter { $0.userID != UserDefaultsManager.shared.userID ?? ""}
                    print("@@@@@@@", filteredList.count)
                    return .just(.setMemberList(filteredList))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceMembers, error.errorCode)))
                }
            }
    }
}
