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
        case doneButtonTapped
    }
    
    enum Mutation {
        case setName(String)
        case setDescription(String)
        case setDoneButtonEnabled(Bool)
        case setActionSheetVisible(Bool)
        case setAlbumVisible(Bool)
        case setCameraVisible(Bool)
        case setImageData(Data)
        
        case setNavigateToHome(Bool)
        
        case setValidName(Bool)
        case setValidImage(Bool)
        case setToastMessage(String)
        
        case setCreateWorkspaceSuccess(Bool)
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        var name = ""
        var description = ""
        var imageData: Data?
        
        var isDoneButtonEnabled = false
        
        var isActionSheetVisible = false
        var isAlbumVisible = false
        var isCameraVisible = false
        
        var shouldNavigateToHome = false
        
        var isValidName = false
        var isValidImage = false
        @Pulse var toastMessage: String?
        
        var isCreateWorkspaceSuccess = false
        var networkError: (Router.APIType, String?) = (.empty, nil)
    }
    
    let initialState: State = State()
    
    private let disposeBag = DisposeBag()
    
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
            let isValid = isValidWorkspaceName(name: value)
            
            return .concat([
                .just(.setName(value)),
                .just(.setValidName(isValid)),
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
            let isValid = isValidPhotoImage(image: value)
            
            return .concat([
                .just(.setImageData(value)),
                .just(.setValidImage(isValid))
            ])
        
        case .xButtonTapped:
            //이전화면에 따라 동작 분기 처리
            switch self.previousScreen {
            case .workspaceInitial:
                return .concat([
                    removeRecentWorkspaceID(),
                    .just(.setNavigateToHome(true))
                ])
                
            case .workspaceList:
                return .just(.setNavigateToHome(true))
            }
        
        case .doneButtonTapped:
            if let invalidMessage = makeInvalidMessage(name: currentState.name, image: currentState.imageData) {
                return .concat([
                    .just(.setToastMessage(invalidMessage))
                ])
            } else {
                //생성 진행
                return createWorkspace()
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
        
        case .setNavigateToHome(let value):
            newState.shouldNavigateToHome = value
        
        case .setValidName(let value):
            newState.isValidName = value
        
        case .setValidImage(let value):
            newState.isValidImage = value
        
        case .setToastMessage(let value):
            newState.toastMessage = value
        
        case .setCreateWorkspaceSuccess(let value):
            newState.isCreateWorkspaceSuccess = value
        
        case .setNetworkError(let value):
            newState.networkError = value
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
    
    private func isValidWorkspaceName(name: String) -> Bool {
        return name.trimmingCharacters(in: .whitespaces).count >= 1 && name.trimmingCharacters(in: .whitespaces).count <= 30
    }
    
    private func isValidPhotoImage(image: Data?) -> Bool {
        return image != nil
    }
    
    private func makeInvalidMessage(name: String, image: Data?) -> String? {
        if !isValidWorkspaceName(name: name) {
            return "워크스페이스 이름은 1~30자로 설정해주세요."
        }
        
        if !isValidPhotoImage(image: image) {
            return "워크스페이스 이미지를 등록해주세요."
        }
        
        return nil //유효한 경우로 판별
    }
    
    //워크스페이스 생성 네트워크 작업 실행
    private func createWorkspace() -> Observable<Mutation> {
        NetworkManager.shared.performRequestMultipartFormData(api: .createWorkspace(name: currentState.name, description: currentState.description, imageData: currentState.imageData ?? Data()), model: WorkspaceList.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    print("DEBUG: 워크스페이스 생성 성공")
                    
                    UserDefaultsManager.shared.recentWorkspaceID = value.id
                    
                    return .concat([
                        .just(.setCreateWorkspaceSuccess(true))
                    ])
                
                case .failure(let error):
                    print("DEBUG: 워크스페이스 생성 실패")
                    let errorCodeValue = error.errorCode
                    return .concat([
                        .just(.setCreateWorkspaceSuccess(false)),
                        .just(.setNetworkError((Router.APIType.createWorkspace, errorCodeValue))),
                        .just(.setNetworkError((Router.APIType.empty, nil)))
                    ])
                }
            }
    }
}
