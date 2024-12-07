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
        case inputName(String)
        case inputDescription(String)
        case selectPhotoImage(Data)
        case doneButtonTapped
        case xMarkButtonTapped
    }
    
    enum Mutation {
        case setWorkspaceName(String)
        case setWorkspaceDescription(String)
        case setDoneButtonEnabled(Bool)
        case setNetworkError((Router.APIType, String?))
        case setPhotoImageData(Data)
        case setNavigateToWorkspaceList
    }
    
    struct State {
        @Pulse var workspaceName: String?
        @Pulse var workspaceImagePath: String?
        @Pulse var workspaceDescription: String?
        @Pulse var workspaceImageData: Data?
        @Pulse var isDoneButtonEnabled: Bool?
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var navigateToWorkspaceLit: Void?
    }
    
    let initialState: State
    
    init(workspace: Workspace) {
        self.initialState = State(
            workspaceName: workspace.name,
            workspaceImagePath: workspace.coverImage,
            workspaceDescription: workspace.description,
            isDoneButtonEnabled: true
        )
    }
}

//MARK: - Mutate

extension WorkspaceEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputName(let value):
            
            let isEnabled = value.trimmingCharacters(in: .whitespaces).isEmpty ? false : true
            
            return .concat([
                .just(.setWorkspaceName(value)),
                .just(.setDoneButtonEnabled(isEnabled))
            ])
            
        case .inputDescription(let value):
            return .just(.setWorkspaceDescription(value))
        
        case .selectPhotoImage(let value):
            return .just(.setPhotoImageData(value))
        
        case .doneButtonTapped:
            return executeWorkspaceEdit()
        
        case .xMarkButtonTapped:
            return .just(.setNavigateToWorkspaceList)
        }
    }
}

//MARK: - Reduce

extension WorkspaceEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setWorkspaceName(let value):
            newState.workspaceName = value
            
        case .setWorkspaceDescription(let value):
            newState.workspaceDescription = value
        
        case .setDoneButtonEnabled(let value):
            newState.isDoneButtonEnabled = value
            
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setPhotoImageData(let value):
            newState.workspaceImageData = value
            
        case .setNavigateToWorkspaceList:
            newState.navigateToWorkspaceLit = ()
        }
        return newState
    }
}

//MARK: - Logic

extension WorkspaceEditReactor {
    private func executeWorkspaceEdit() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        guard let name = currentState.workspaceName else { return .empty() }
        let description = currentState.workspaceDescription
        let imageData = currentState.workspaceImageData
        
        return NetworkManager.shared.performRequestMultipartFormData(api: .workspaceEdit(workspaceID: workspaceID, name: name, description: description, imageData: imageData), model: Workspace.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: .workspaceEditComplete, object: nil)
                    return .just(.setNavigateToWorkspaceList)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceEdit, error.errorCode)))
                }
            }
    }
}
