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
    }
    
    enum Mutation {
        case setNewNickname(String)
        case setDoneButtonEnabled(Bool)
    }
    
    struct State {
        var nickname: String //변경 전
        var newNickname: String //새로운 닉네임
        @Pulse var placeholderText: String = "닉네임을 입력해주세요."
        var isDoneButtonEnabled: Bool = true
    }
    
    let initialState: State
    
    init(nickname: String) {
        self.initialState = State(
            nickname: nickname,
            newNickname: nickname
        )
    }
}

//MARK: - Mutate

extension NicknameEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNewNickname(let value):
            let isValid = value.trimmingCharacters(in: .whitespaces).isEmpty ? false : true
            
            return .concat([
                .just(.setDoneButtonEnabled(isValid)),
                .just(.setNewNickname(value))
            ])
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
        }
        return newState
    }
}

