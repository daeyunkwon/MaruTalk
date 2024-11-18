//
//  WorkspaceAddReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/12/24.
//

import Foundation

import ReactorKit

final class WorkspaceAddReactor: Reactor {
    enum Action {
        case inputName(String)
        case inputDescription(String)
        
        case imageSettingButtonTapped
        case selectPhotoFromAlbum
        case selectPhotoFromCamera
        case selectPhotoImage(Data)
        
        case xButtonTapped
    }
    
    enum Mutation {
        case setName(String)
        case setDescription(String)
        case setDoneButtonEnabled(Bool)
        case setActionSheetVisible(Bool)
        case setAlbumVisible(Bool)
        case setCameraVisible(Bool)
        case setImageData(Data)
        
        case setNavigateToHomeEmpty(Bool)
    }
    
    struct State {
        var name = ""
        var description = ""
        var imageData = Data()
        
        var isDoneButtonEnabled = false
        
        var isActionSheetVisible = false
        var isAlbumVisible = false
        var isCameraVisible = false
        
        var shouldNavigateToHomeEmpty = false
    }
    
    let initialState: State = State()
    
    enum PreviousScreen {
        case workspaceInitial
        case workspaceList
    }
    private var previousScreen: PreviousScreen
    
    init(previousScreen: PreviousScreen) {
        self.previousScreen = previousScreen
    }
}

//MARK: - Mutate

extension WorkspaceAddReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputName(let value):
            let isEnabled = isDoneButtonEnabled(name: value)
            
            return .concat([
                .just(.setName(value)),
                .just(.setDoneButtonEnabled(isEnabled))
            ])
        
        case .inputDescription(let value):
            
            return .concat([
                .just(.setDescription(value)),
            ])
            
        case .imageSettingButtonTapped:
            return .concat([
                .just(.setActionSheetVisible(true)),
                .just(.setActionSheetVisible(false))
            ])
        case .selectPhotoFromAlbum:
            return .concat([
                .just(.setAlbumVisible(true)),
                .just(.setAlbumVisible(false))
            ])
            
        case .selectPhotoFromCamera:
            return .concat([
                .just(.setCameraVisible(true)),
                .just(.setCameraVisible(false))
            ])
        
        case .selectPhotoImage(let value):
            return .just(.setImageData(value))
        
        case .xButtonTapped:
            //이전화면에 따라 동작 분기 처리
            switch self.previousScreen {
            case .workspaceInitial:
                print(11111)
                return .concat([
                    removeRecentWorkspaceID(),
                    .just(.setNavigateToHomeEmpty(true))
                ])
                
            case .workspaceList:
                return .empty()
            }
        }
    }
}

//MARK: - Reduce

extension WorkspaceAddReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setName(let value):
            newState.name = value
        
        case .setDescription(let value):
            newState.description = value
            
        case .setDoneButtonEnabled(let value):
            newState.isDoneButtonEnabled = value
            
        case .setActionSheetVisible(let value):
            newState.isActionSheetVisible = value
        
        case .setAlbumVisible(let value):
            newState.isAlbumVisible = value
        
        case .setCameraVisible(let value):
            newState.isCameraVisible = value
        
        case .setImageData(let value):
            newState.imageData = value
        
        case .setNavigateToHomeEmpty(let value):
            newState.shouldNavigateToHomeEmpty = value
        }
        return newState
    }
}

//MARK: - Logic

extension WorkspaceAddReactor {
    private func isDoneButtonEnabled(name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func removeRecentWorkspaceID() -> Observable<Mutation> {
        return .create { observer in
            UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
