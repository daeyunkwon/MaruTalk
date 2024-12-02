//
//  ProfileReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import Foundation

import ReactorKit

final class ProfileReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        @Pulse var sections: [ProfileSectionModel] = [
            ProfileSectionModel(header: "first", items: [
                .init(title: "내 새싹 코인", subTitle: "충전하기"),
                .init(title: "닉네임", subTitle: ""),
                .init(title: "연락처", subTitle: "")
            ]),
            ProfileSectionModel(header: "second", items: [
                .init(title: "이메일", subTitle: ""),
                .init(title: "연결된 소셜 계정", subTitle: ""),
                .init(title: "로그아웃", subTitle: "")
            ])
        ]
    }
    
    var initialState: State = State()
}

//MARK: - Mutate

extension ProfileReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

//MARK: - Reduce

extension ProfileReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        }
        return newState
    }
}
