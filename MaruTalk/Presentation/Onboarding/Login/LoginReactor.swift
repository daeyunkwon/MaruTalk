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
    }
    
    struct State {
        var shouldNavigateToAuth = false
        var shouldNavigateToHome = false
        var email = ""
        var password = ""
        var isValidEmail = false
        var isValidPassword = false
        var isLoginButtonEnabled = false
        @Pulse var validationStates: [Bool] = []
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
                return .empty()
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
            newState.shouldNavigateToAuth = value
        
        case .setNavigateToHome(let value):
            newState.shouldNavigateToHome = value
            
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
}
