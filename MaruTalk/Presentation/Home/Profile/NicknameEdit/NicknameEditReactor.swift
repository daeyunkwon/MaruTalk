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
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        @Pulse var nickname: String
        @Pulse var placeholderText: String = "닉네임을 입력해주세요."
    }
    
    let initialState: State
    
    init(nickname: String) {
        self.initialState = State(nickname: nickname)
    }
}

//MARK: - Mutate

extension NicknameEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

//MARK: - Reduce

extension NicknameEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        
    }

}

