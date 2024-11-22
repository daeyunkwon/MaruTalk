//
//  AuthReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/20/24.
//

import Foundation
import AuthenticationServices

import KakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKUser
import ReactorKit

final class AuthReactor: Reactor {
    enum Action {
        case loginWithApple(appleIdCredential: ASAuthorizationAppleIDCredential)
        case loginWithKakao
    }
    
    enum Mutation {
        case setLoginSuccess(Bool)
        case setLoginInProgress(Bool)
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        var loginSuccess = false
        var isLoginInProgress = false
        @Pulse var networkError: (Router.APIType, String?) = (Router.APIType.empty, nil)
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension AuthReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loginWithApple(let appleIdCredential):
            return saveAppleLoginCredentials(appleIdCredential: appleIdCredential)
                .withUnretained(self)
                .flatMap { _ -> Observable<Mutation> in
                    return .concat([
                        .just(.setLoginInProgress(true)),
                        self.executeLoginWithApple(),
                        .just(.setLoginInProgress(false))
                    ])
                }
        
        case .loginWithKakao:
            return saveKakaoLoginToken()
                .withUnretained(self)
                .flatMap { _ -> Observable<Mutation> in
                    return .concat([
                        self.executeLoginWithKakao()
                    ])
                }
        }
    }
}

//MARK: - Reduce

extension AuthReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoginSuccess(let value):
            newState.loginSuccess = value
        
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setLoginInProgress(let value):
            newState.isLoginInProgress = value
        }
        return newState
    }
}

//MARK: - Logic

extension AuthReactor {
    //Keychain에 정보 저장
    private func saveAppleLoginCredentials(appleIdCredential: ASAuthorizationAppleIDCredential) -> Observable<Void> {
        let userIdentifier = appleIdCredential.user
        let fullName = appleIdCredential.fullName
        let email = appleIdCredential.email
        let identityToken = appleIdCredential.identityToken
        
        //이메일, 이름, 토큰 저장 (이메일과 이름은 처음 가입 시 1번만 저장됨)
        //최초 가입 시 닉네임을 유저 이름으로 활용
        if let email = email {
            let _ = KeychainManager.shared.saveItem(item: email, forKey: .appleUserEmail)
        }
        
        if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
            let fullNameString = "\(givenName) \(familyName)"
            let _ = KeychainManager.shared.saveItem(item: fullNameString, forKey: .appleUserName)
            let _ = KeychainManager.shared.saveItem(item: fullNameString, forKey: .appleUserNickname)
        }
        
        if let identityToken = identityToken {
            let identityTokenString = String(data: identityToken, encoding: .utf8) ?? ""
            let _ = KeychainManager.shared.saveItem(item: identityTokenString, forKey: .appleUserToken)
        }
        
        print("DEBUG: Apple ID 로그인에 성공하였습니다.")
        print("사용자 ID: \(userIdentifier)")
        print("전체 이름: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
        print("이메일: \(email ?? "")")
        print("Token: \(identityToken ?? Data())")
        print("---------------------------------")
        
        return Observable.just(())
    }
    
    //서버에 애플 로그인 요청
    private func executeLoginWithApple() -> Observable<Mutation> {
        guard let idToken = KeychainManager.shared.getItem(forKey: .appleUserToken) else { return .empty() }
        guard let nickname = KeychainManager.shared.getItem(forKey: .appleUserNickname) else { return .empty() }
        let deviceToken = ""
        
        return NetworkManager.shared.performRequest(api: .loginWithApple(idToken: idToken, nickname: nickname, deviceToken: deviceToken), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    //토큰 저장
                    let isAcessTokenSaved = KeychainManager.shared.saveItem(item: value.token?.accessToken ?? "", forKey: .accessToken)
                    let isRefreshTokenSaved = KeychainManager.shared.saveItem(item: value.token?.refreshToken ?? "", forKey: .refreshToken)
                    //토큰 저장 정상 처리 시 워크스페이스 조회
                    if isAcessTokenSaved && isRefreshTokenSaved {
                        return self.fetchWorkspace()
                    } else {
                        print("ERROR: 토큰 저장 실패")
                        return .empty()
                    }
                
                case .failure(let error):
                    let errorCode = error.errorCode
                    return .just(.setNetworkError((Router.APIType.loginWithApple, errorCode)))
                }
            }
    }
    
    //Keychain에 토큰 저장
    private func saveKakaoLoginToken() -> Observable<Void> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .do(onNext: { oauthToken in
                    print("DEBUG: loginWithKakaoTalk() success.")
                    
                    //서버에 로그인 요청하기 위해 oauthToken 필요
                    let _ = KeychainManager.shared.saveItem(item: oauthToken.accessToken, forKey: .kakaoOauthToken)
                    
                    // 토큰 저장 등의 작업 수행
                })
                .map { _ in } // Void 반환으로 변환
        } else {
            print("DEBUG: KakaoTalkLogin disabled")
            return Observable<Void>.just(())
        }
    }
    
    //서버에 카카오톡 로그인 요청
    private func executeLoginWithKakao() -> Observable<Mutation> {
        guard let oauthToken = KeychainManager.shared.getItem(forKey: .kakaoOauthToken) else { return .empty() }
        let deviceToken = ""
        
        return NetworkManager.shared.performRequest(api: .loginWithKakao(oauthToken: oauthToken, deviceToken: deviceToken), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    //토큰 저장
                    let isAcessTokenSaved = KeychainManager.shared.saveItem(item: value.token?.accessToken ?? "", forKey: .accessToken)
                    let isRefreshTokenSaved = KeychainManager.shared.saveItem(item: value.token?.refreshToken ?? "", forKey: .refreshToken)
                    //토큰 저장 정상 처리 시 워크스페이스 조회
                    if isAcessTokenSaved && isRefreshTokenSaved {
                        return self.fetchWorkspace()
                    } else {
                        print("ERROR: 토큰 저장 실패")
                        return .empty()
                    }
                
                case .failure(let error):
                    let errorCode = error.errorCode
                    return .just(.setNetworkError((Router.APIType.loginWithKakao, errorCode)))
                }
            }
    }
    
    //워크스페이스 조회
    private func fetchWorkspace() -> Observable<Mutation> {
        return NetworkManager.shared.performRequest(api: .workspaces, model: [WorkspaceList].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    print("DEBUG: 조회된 워크스페이스 목록: ", value)
                    if !value.isEmpty {
                        let sortedValue = value.sorted {
                            $0.createdDate > $1.createdDate
                        }
                        UserDefaultsManager.shared.recentWorkspaceID = sortedValue.first?.id
                    } else {
                        UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                    }
                    
                    return .just(.setLoginSuccess(true))
                
                case .failure(let error):
                    let errorCode = error.errorCode
                    return .just(.setNetworkError((Router.APIType.workspaces, errorCode)))
                }
            }
    }
}
