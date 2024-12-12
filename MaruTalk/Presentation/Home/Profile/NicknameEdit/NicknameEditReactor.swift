//
//  NicknameEditReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/12/24.
//

import Foundation

import ReactorKit

final class NicknameEditReactor: Reactor {
    enum Action {
        case inputNewNickname(String)
        case doneButtonTapped
    }
    
    enum Mutation {
        case setNewNickname(String)
        case setDoneButtonEnabled(Bool)
        case setNavigateToProfile
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        let user: User
        var newNickname: String //새로운 닉네임
        @Pulse var placeholderText: String = "닉네임을 입력해주세요."
        var isDoneButtonEnabled: Bool = true
        @Pulse var navigateToProfile: Void?
        @Pulse var networkError: (Router.APIType, String?)?
    }
    
    let initialState: State
    
    init(user: User) {
        self.initialState = State(user: user, newNickname: user.nickname)
    }
}

//MARK: - Mutate

extension NicknameEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNewNickname(let value):
            let isValid: Bool
            
            if !value.trimmingCharacters(in: .whitespaces).isEmpty && value.count <= 30 {
                isValid = true
            } else {
                isValid = false
            }
            
            return .concat([
                .just(.setDoneButtonEnabled(isValid)),
                .just(.setNewNickname(value))
            ])
        
        case .doneButtonTapped:
            if currentState.user.nickname == currentState.newNickname {
                //변경사항이 없는 경우 네트워크 통신 작업없이 프로필 화면으로 전환
                return .just(.setNavigateToProfile)
            } else {
                //프로필 수정 네트워크 통신 작업 실행
                return executeNicknameEdit()
            }
        }
    }
}

//MARK: - Reduce

extension NicknameEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNewNickname(let value):
            newState.newNickname = value
            
        case .setDoneButtonEnabled(let value):
            newState.isDoneButtonEnabled = value
        
        case .setNavigateToProfile:
            newState.navigateToProfile = ()

        case .setNetworkError(let value):
            newState.networkError = value
        }
        return newState
    }
}

//MARK: - Logic

extension NicknameEditReactor {
    private func executeNicknameEdit() -> Observable<Mutation> {
        let nickname = currentState.newNickname
        let phone = currentState.user.phone ?? ""
        
        return NetworkManager.shared.performRequest(api: .userMeEdit(nickname: nickname, phone: phone), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    NotificationCenter.default.post(name: .profileEditComplete, object: nil, userInfo: [NotificationUserInfoKey.user: value])
                    return .just(.setNavigateToProfile)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMeEdit, error.errorCode)))
                }
            }
    }
}
