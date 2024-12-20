//
//  LoginReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/19/24.
//

import Foundation

import ReactorKit

final class LoginReactor: Reactor {
    enum Action {
        case xButtonTapped
        case inputEmail(String)
        case inputPassword(String)
        case loginButtonTapped
    }
    
    enum Mutation {
        case setNavigateToAuth(Bool)
        case setNavigateToHome(Bool)
        case setEmail(String)
        case setPassword(String)
        case setValidEmail(Bool)
        case setValidPassword(Bool)
        case setLoginButtonEnabled(Bool)
        case setValidationStates([Bool])
        case setNetworkError((Router.APIType, String?))
        case setLoginInProgress(Bool)
    }
    
    struct State {
        var navigateToAuth = false
        var navigateToHome = false
        var email = ""
        var password = ""
        var isValidEmail = false
        var isValidPassword = false
        var isLoginButtonEnabled = false
        @Pulse var validationStates: [Bool] = []
        @Pulse var networkError: (Router.APIType, String?) = (Router.APIType.empty, nil)
        var isLoginInProgress = false
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension LoginReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .xButtonTapped:
            return .just(.setNavigateToAuth(true))
            
        case .inputEmail(let value):
            let isEnabled = isLoginButtonEnabled(email: value, password: currentState.password)
            return .concat([
                .just(.setEmail(value)),
                .just(.setValidEmail(isValidEmail(email: value))),
                .just(.setLoginButtonEnabled(isEnabled))
            ])
            
            
        case .inputPassword(let value):
            let isEnabled = isLoginButtonEnabled(email: currentState.email, password: value)
            return .concat([
                .just(.setPassword(value)),
                .just(.setValidPassword(isValidPassword(password: value))),
                .just(.setLoginButtonEnabled(isEnabled))
            ])
            
        case .loginButtonTapped:
            if currentState.isValidEmail && currentState.isValidPassword {
                return .concat([
                    .just(.setLoginInProgress(true)),
                    executeLogin(),
                    .just(.setLoginInProgress(false))
                ])
            } else {
                return .just(.setValidationStates([currentState.isValidEmail, currentState.isValidPassword]))
            }
        }
    }
}

//MARK: - Reduce

extension LoginReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigateToAuth(let value):
            newState.navigateToAuth = value
        
        case .setNavigateToHome(let value):
            newState.navigateToHome = value
            
        case .setEmail(let value):
            newState.email = value
            
        case .setPassword(let value):
            newState.password = value
        
        case .setValidEmail(let value):
            newState.isValidEmail = value
        
        case .setValidPassword(let value):
            newState.isValidPassword = value
        
        case .setLoginButtonEnabled(let value):
            newState.isLoginButtonEnabled = value
        
        case .setValidationStates(let value):
            newState.validationStates = value
        
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setLoginInProgress(let value):
            newState.isLoginInProgress = value
        }
        return newState
    }
}

//MARK: - Logic

extension LoginReactor {
    //이메일 형식 유효성 검사
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    //비밀번호 유효성 검사
    private func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!_@$%^&+=-])[A-Z0-9a-z.!_@$%^&+=-]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    private func isLoginButtonEnabled(email: String, password: String) -> Bool {
        return !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    //로그인 요청
    private func executeLogin() -> Observable<Mutation> {
        let email: String = currentState.email
        let password: String = currentState.password
        let deviceToken: String = FCMManager.shared.getFCMToken()
        
        return NetworkManager.shared.performRequest(api: .login(email: email, password: password, deviceToken: deviceToken), model: User.self)
            .asObservable()
            .flatMap {[weak self] result -> Observable<Mutation> in
                guard let self else { return .empty()}
                switch result {
                case .success(let value):
                    print("DEBUG: 로그인 유저 정보-------------")
                    print(value)
                    print("--------------------------------")
                    //유저 ID 저장
                    UserDefaultsManager.shared.userID = value.userID
                    print("유저ID: \(value.userID)")
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
                    return .just(.setNetworkError((Router.APIType.login, errorCode)))
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
                    print(value)
                    if !value.isEmpty {
                        //사용자가 속한 워크스페이스가 있는 경우
                        let sortedValue = value.sorted {
                            $0.createdDate > $1.createdDate
                        }
                        //조회된 워크스페이스 목록 중에 해당되는 최근에 조회한 워크스페이스가 없는 경우 임의 지정하기
                        if UserDefaultsManager.shared.recentWorkspaceID == nil {
                            UserDefaultsManager.shared.recentWorkspaceID = sortedValue.first?.id
                            UserDefaultsManager.shared.recentWorkspaceOwnerID = sortedValue.first?.ownerID
                        } else if !value.contains(where: { $0.id == UserDefaultsManager.shared.recentWorkspaceID ?? ""}) {
                            UserDefaultsManager.shared.recentWorkspaceID = sortedValue.first?.id
                            UserDefaultsManager.shared.recentWorkspaceOwnerID = sortedValue.first?.ownerID
                        }
                    } else {
                        //사용자가 속한 워크스페이스가 없는 경우
                        UserDefaultsManager.shared.removeItem(key: .recentWorkspaceID)
                        UserDefaultsManager.shared.removeItem(key: .recentWorkspaceOwnerID)
                    }
                    
                    return .just(.setNavigateToHome(true))
                
                case .failure(let error):
                    let errorCode = error.errorCode
                    return .just(.setNetworkError((Router.APIType.workspaces, errorCode)))
                }
            }
    }
}
