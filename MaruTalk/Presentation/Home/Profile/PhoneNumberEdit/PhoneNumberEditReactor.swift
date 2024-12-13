//
//  PhoneNumberEditReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/13/24.
//

import Foundation

import ReactorKit

final class PhoneNumberEditReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var user: User
        var newPhoneNumber: String
        @Pulse var placeholderText: String = "연락처를 입력해주세요."
    }
    
    let initialState: State
    
    init(user: User) {
        self.initialState = State(user: user, newPhoneNumber: user.phone ?? "")
    }
}

//MARK: - Mutate

extension PhoneNumberEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

//MARK: - Reduce

extension PhoneNumberEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        
    }

}
