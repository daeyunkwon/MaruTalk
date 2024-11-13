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
    }
    
    enum Mutation {
        case setName(String)
        case setDescription(String)
        case setDoneButtonEnabled(Bool)
        case setActionSheetVisible(Bool)
        case setAlbumVisible(Bool)
        case setCameraVisible(Bool)
        case setImageData(Data)
    }
    
    struct State {
        var name = ""
        var description = ""
        var imageData = Data() {
            didSet {
                print(self)
            }
        }
        
        var isDoneButtonEnabled = false
        
        var isActionSheetVisible = false
        var isAlbumVisible = false
        var isCameraVisible = false
    }
    
    let initialState: State = State()
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
        }
        return newState
    }
}

//MARK: - Logic

extension WorkspaceAddReactor {
    func isDoneButtonEnabled(name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
