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
        case fetch
        case update(User)
        case profileImageChange(Data)
        case selectNickname
        case selectPhoneNumber
        case logout
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setSections(User)
        case setUser(User)
        case setProfileImagePath(String?)
        case setNavigateToNicknameEdit(User)
        case setNavigateToPhoneNumberEdit(User)
        case setNavigateToOnboarding
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
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var profileImagePath: String?
        @Pulse var navigateToOnboarding: Void?
        
        var user: User?
        @Pulse var navigateToNicknameEdit: User?
        @Pulse var navigateToPhoneNumberEdit: User?
    }
    
    var initialState: State = State()
}

//MARK: - Mutate

extension ProfileReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return fetchProfile()
            
        case .update(let value):
            guard var user = currentState.user else { return .empty() }
            user.nickname = value.nickname
            user.phone = value.phone
            
            return .concat([
                .just(.setSections(user)),
                .just(.setUser(user))
            ])
        
        case .profileImageChange(let value):
            return executeProfileImageChange(imageData: value)
            
        case .selectNickname:
            if let user = currentState.user {
                return .just(.setNavigateToNicknameEdit(user))
            } else {
                return .empty()
            }
            
        case .selectPhoneNumber:
            if let user = currentState.user {
                return .just(.setNavigateToPhoneNumberEdit(user))
            } else {
                return .empty()
            }
        
        case .logout:
            return executeLogout()
        }
    }
}

//MARK: - Reduce

extension ProfileReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setSections(let value):
            newState.sections = [
                ProfileSectionModel(header: "first", items: [
                    .init(title: "내 새싹 코인", subTitle: "\(value.sesacCoin ?? 0) | 충전하기"),
                    .init(title: "닉네임", subTitle: value.nickname),
                    .init(title: "연락처", subTitle: value.phone ?? "")
                ]),
                ProfileSectionModel(header: "second", items: [
                    .init(title: "이메일", subTitle: value.email),
                    .init(title: "연결된 소셜 계정", subTitle: value.provider ?? ""),
                    .init(title: "로그아웃", subTitle: "")
                ])
            ]
        
        case .setProfileImagePath(let value):
            newState.profileImagePath = value
        
        case .setNavigateToOnboarding:
            newState.navigateToOnboarding = ()
        
        case .setUser(let value):
            newState.user = value
        
        case .setNavigateToNicknameEdit(let value):
            newState.navigateToNicknameEdit = value
        
        case .setNavigateToPhoneNumberEdit(let value):
            newState.navigateToPhoneNumberEdit = value
        }
        return newState
    }
}

//MARK: - Logic

extension ProfileReactor {
    private func fetchProfile() -> Observable<Mutation> {
        return NetworkManager.shared.performRequest(api: .userMe, model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .concat([
                        .just(.setUser(value)),
                        .just(.setProfileImagePath(value.profileImage)),
                        .just(.setSections(value))
                    ])
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMe, error.errorCode)))
                }
            }
    }
    
    //프로필 이미지 수정
    private func executeProfileImageChange(imageData: Data) -> Observable<Mutation> {
        return NetworkManager.shared.performRequestMultipartFormData(api: .userMeImage(imageData: imageData), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setProfileImagePath(value.profileImage))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMeImage, error.errorCode)))
                }
            }
    }
    
    //로그아웃(서버에 저장된 FCM deviceToken 정보 삭제)
    private func executeLogout() -> Observable<Mutation> {
        return NetworkManager.shared.performRequset(api: .logout)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success():
                    UserDefaultsManager.shared.removeItem(key: .userID)
                    UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                    UserDefaultsManager.shared.removeItem(key: .recentWorkspaceOwnerID)
                    return .just(.setNavigateToOnboarding)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.logout, error.errorCode)))
                }
            }
    }
}
