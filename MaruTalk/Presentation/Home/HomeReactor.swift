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
        case fetch
        case workspaceAddButtonTapped
    }
    
    enum Mutation {
        case setExpanded(isExpanded: Bool, sectionIndex: Int)
        case setShowEmpty(Bool)
        case setNavigateToWorkspaceAdd
        case setNetworkError((Router.APIType, String?))
        case setWorkspace(Workspace)
        case setUser(User)
        case setChannelSection([Channel])
    }
    
    struct State {
        @Pulse var sections: [SectionModel] = [
            SectionModel(headerTitle: "채널", items: [], index: 0),
            SectionModel(headerTitle: "다이렉트 메시지", items: [.dm("첫번째"), .dm("두번째"), .add("새 메시지 시작")], index: 1),
            SectionModel(headerTitle: "팀원 추가", items: [], index: 2)
        ] {
            didSet {
                print(sections[0])
            }
        }
        
        var channelSectionModel = SectionModel(headerTitle: "채널", items: [], index: 0)
        
        @Pulse var isShowEmpty: Bool = false
        @Pulse var shouldNavigateToWorkspaceAdd: Void = ()
        @Pulse var workspace: Workspace?
        @Pulse var user: User?
        
        @Pulse var networkError: (Router.APIType, String?) = (Router.APIType.empty, nil)
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
            
            return .concat([
                .just(.setExpanded(isExpanded: isExpanded, sectionIndex: sectionIndex))
            ])
            
        case .fetch:
            let isShowEmpty = UserDefaultsManager.shared.recentWorkspaceID == nil ? true : false
            //조회할 워크스페이스가 없는 경우 HomeEmpty UI 표시하기
            if isShowEmpty {
                return .just(.setShowEmpty(isShowEmpty))
            } else {
                return .concat([
                    .just(.setShowEmpty(false)),
                    fetchWorkspace(),
                    fetchProfile(),
                    fetchMyChannels()
                ])
            }
        
        case .workspaceAddButtonTapped:
            return .just(.setNavigateToWorkspaceAdd)
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
                switch sectionIndex {
                case 0:
                    newState.sections[0].items = currentState.channelSectionModel.items
                case 1: break
                default: break
                }
            } else {
                switch sectionIndex {
                case 0: newState.sections[0].items = []
                case 1: break
                default: break
                }
            }
            
        case .setShowEmpty(let value):
            newState.isShowEmpty = value
        
        case .setNavigateToWorkspaceAdd:
            newState.shouldNavigateToWorkspaceAdd = ()
        
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setWorkspace(let value):
            newState.workspace = value
        
        case .setUser(let value):
            newState.user = value
        
        case .setChannelSection(let value):
            var items: [SectionItem] = value.map { .channel($0.name) }
            items.append(.add("채널 추가"))
            
            newState.channelSectionModel.items = items
            newState.channelSectionModel.isExpanded = true
        }
        return newState
    }
}

//MARK: - Logic

extension HomeReactor {
    //특정 워크스페이스 조회
    private func fetchWorkspace() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty()}
        return NetworkManager.shared.performRequest(api: .workspace(id: workspaceID), model: [Workspace].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return value.isEmpty ? .empty() : .just(.setWorkspace(value[0]))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspace, error.errorCode)))
                }
            }
    }
    
    //내 프로필 조회
    private func fetchProfile() -> Observable<Mutation> {
        return NetworkManager.shared.performRequest(api: .userMe, model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setUser(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMe, error.errorCode)))
                }
            }
    }
    
    //속한 채널 조회
    private func fetchMyChannels() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        return NetworkManager.shared.performRequest(api: .myChannels(workspaceID: workspaceID), model: [Channel].self)
            .asObservable()
            .flatMap { [weak self] result -> Observable<Mutation> in
                guard let self else { return .empty() }
                switch result {
                case .success(let value):
                    return .just(.setChannelSection(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMe, error.errorCode)))
                }
            }
    }
}


