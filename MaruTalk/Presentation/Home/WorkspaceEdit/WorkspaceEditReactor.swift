//
//  WorkspaceEditReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/5/24.
//

import Foundation

import ReactorKit

final class WorkspaceEditReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        @Pulse var workspaceName: String?
        @Pulse var workspaceImagePath: String?
        @Pulse var workspaceDescription: String?
    }
    
    let initialState: State
    
    init(workspace: Workspace) {
        self.initialState = State(
            workspaceName: workspace.name,
            workspaceImagePath: workspace.coverImage,
            workspaceDescription: workspace.description
        )
    }
}

//MARK: - Mutate

extension WorkspaceEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

//MARK: - Reduce

extension WorkspaceEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
