//
//  SignUpReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/3/24.
//

import Foundation

import ReactorKit
import RxSwift

final class SignUpReactor: Reactor {
    //사용자가 UI에서 수행할 수 있는 작업
    enum Action {
        case closeButtonTapped
        case inputEmail(String)
        case emailCheckButtonTapped
        case inputNickname(String)
        case inputPhoneNumber(String)
        case inputPassword(String)
        case inputPasswordCheck(String)
    }
    //Action을 처리할 때 발생하는 상태 변화를 정의
    enum Mutation {
        case emailValue(String)
        case nicknameValue(String)
        case phoneNumberValue(String)
        case passwordValue(String)
        case passwordCheckValue(String)
        case setEmailDuplicateCheckButtonEnabled(Bool)
        case setSignUpButtonEnabled(Bool)
        case close
    }
    //UI에 표시할 데이터
    struct State {
        var email = ""
        var nickname = ""
        var phoneNumber = ""
        var password = ""
        var passwordCheck = ""
        var emailDuplicateCheckButtonEnabled = false
        var signUpButtonEnabled = false
        var shouldClose = false
    }
    
    let initialState: State = State()
    
//    init(initialState: State) {
//        self.initialState = initialState
//    }
}

//MARK: - Mutate

extension SignUpReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .closeButtonTapped:
            return .just(Mutation.close)
            
        case .inputEmail(let value):
            let isEmailCheckButtonEnabled = isEmailDuplicateCheckButtonEnabled(email: value)
            let isEnabled = isSignUpButtonEnabled(email: value, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: currentState.passwordCheck)
            
            return Observable.concat([
                Observable.just(Mutation.emailValue(value)),
                Observable.just(Mutation.setEmailDuplicateCheckButtonEnabled(isEmailCheckButtonEnabled)),
                .just(Mutation.setSignUpButtonEnabled(isEnabled))
            ])
            
        case .emailCheckButtonTapped:
            return .just(Mutation.close) //임시
            
        case .inputNickname(let value): 
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: value, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: currentState.passwordCheck)
            return .merge(.just(Mutation.nicknameValue(value)), .just(Mutation.setSignUpButtonEnabled(isEnabled)))
            
        case .inputPhoneNumber(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: value, password: currentState.password, passwordCheck: currentState.passwordCheck)
            return .merge(.just(Mutation.phoneNumberValue(value)), .just(Mutation.setSignUpButtonEnabled(isEnabled)))
            
        case .inputPassword(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: value, passwordCheck: currentState.passwordCheck)
            return .merge(.just(Mutation.passwordValue(value)), .just(Mutation.setSignUpButtonEnabled(isEnabled)))
            
        case .inputPasswordCheck(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: value)
            return .concat(.just(Mutation.passwordCheckValue(value)), .just(Mutation.setSignUpButtonEnabled(isEnabled)))
        }
    }
}

//MARK: - Reduce

extension SignUpReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .emailValue(let value):
            newState.email = value
        
        case .setEmailDuplicateCheckButtonEnabled(let value):
            newState.emailDuplicateCheckButtonEnabled = value
            
        case .close:
            newState.shouldClose = true
            
        case .nicknameValue(let value):
            newState.nickname = value
            
        case .phoneNumberValue(let value):
            newState.phoneNumber = value
            
        case .passwordValue(let value):
            newState.password = value
            
        case .passwordCheckValue(let value):
            newState.passwordCheck = value
            
        case .setSignUpButtonEnabled(let value):
            newState.signUpButtonEnabled = value
        }
        return newState
    }
}

//MARK: - Logic

extension SignUpReactor {
    private func isEmailDuplicateCheckButtonEnabled(email: String) -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func isSignUpButtonEnabled(email: String, nickname: String, phoneNumber: String, password: String, passwordCheck: String) -> Bool {
        return !email.trimmingCharacters(in: .whitespaces).isEmpty && !nickname.trimmingCharacters(in: .whitespaces).isEmpty && !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty && !password.trimmingCharacters(in: .whitespaces).isEmpty && !passwordCheck.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
