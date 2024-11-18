//
//  HomeReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/16/24.
//

import Foundation

import ReactorKit

final class HomeReactor: Reactor {
    enum Action {
        case sectionTapped(Int)
        case checkWorkspace
    }
    
    enum Mutation {
        case setExpanded(isExpanded: Bool, sectionIndex: Int)
        
        case setShowEmpty(Bool)
    }
    
    struct State {
        var sections: [SectionModel] = [
            SectionModel(headerTitle: "채널", items: [.channel("첫번째"), .channel("두번째"), .add("채널 추가")], index: 0),
            SectionModel(headerTitle: "다이렉트 메시지", items: [.dm("첫번째"), .dm("두번째"), .add("새 메시지 시작")], index: 1),
            SectionModel(headerTitle: "팀원 추가", items: [], index: 2)
        ]
        var isShowEmpty: Bool = false
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sectionTapped(let sectionIndex):
            var isExpanded = currentState.sections[sectionIndex].isExpanded
            isExpanded.toggle()
            
            return .just(.setExpanded(isExpanded: isExpanded, sectionIndex: sectionIndex))
            
        case .checkWorkspace:
            let isShowEmpty = UserDefaultsManager.shared.recentWorkspaceID == nil ? true : false
            return .just(.setShowEmpty(isShowEmpty))
        }
    }
}

//MARK: - Reduce

extension HomeReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setExpanded(let isExpanded, let sectionIndex):
            newState.sections[sectionIndex].isExpanded = isExpanded
            if isExpanded {
                newState.sections[1].items = [.dm("asd"), .dm("wwww")]
            } else {
                newState.sections[1].items = []
            }
            
        case .setShowEmpty(let value):
            newState.isShowEmpty = value
        }
        return newState
    }
}

//MARK: - Logic

extension HomeReactor {
    
}


