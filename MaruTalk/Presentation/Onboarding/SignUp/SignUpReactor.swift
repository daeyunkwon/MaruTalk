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
    
    private let disposeBag = DisposeBag()
    
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
        case setEmailDuplicateStatus(Bool)
        
        case setEmailValid(Bool)
        case setNicknameValid(Bool)
        
        case toastMessageValue(String)
        case setNetworkError((Router.APIType, String?))
        case close
    }
    //상태 데이터
    struct State {
        var email = ""
        var nickname = ""
        var phoneNumber = ""
        var password = ""
        var passwordCheck = ""
        
        var emailDuplicateCheckButtonEnabled = false
        var signUpButtonEnabled = false
        var shouldClose = false
        var isEmailDuplicateCheckPassed = false //true일 경우 중복 검사 통과로 인식
        
        var isEmailValid = false
        var isNicknameValid = false
        
        var toastMessage: (String) = ""
        var networkError: (Router.APIType, String?) = (Router.APIType.empty, nil)
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
            let isValid = isValidEmail(email: value)
            
            return Observable.concat([
                .just(Mutation.emailValue(value)),
                .just(.setEmailDuplicateCheckButtonEnabled(isEmailCheckButtonEnabled)),
                .just(.setSignUpButtonEnabled(isEnabled)),
                .just(.setEmailDuplicateStatus(false)),
                .just(.setEmailValid(isValid))
            ])
            
        case .emailCheckButtonTapped:
            //앞서 이메일 형식이 유효 여부 고려
            if currentState.isEmailValid {
                //중복 체크 이미 통과한 경우 고려
                if !currentState.isEmailDuplicateCheckPassed {
                    return checkEmailDuplication(email: currentState.email)
                } else {
                    return .concat([
                        .just(.toastMessageValue("사용 가능한 이메일입니다.")),
                        .just(.toastMessageValue(""))
                    ])
                }
            } else {
                return .concat([
                    .just(.toastMessageValue("이메일 형식이 올바르지 않습니다.")),
                    .just(.toastMessageValue(""))
                ])
            }
            
        case .inputNickname(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: value, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: currentState.passwordCheck)
            let isValid = isValidNickname(nickname: value)
            return .merge(
                .just(Mutation.nicknameValue(value)),
                .just(Mutation.setSignUpButtonEnabled(isEnabled)),
                .just(.setNicknameValid(isValid))
            )
            
        case .inputPhoneNumber(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: value, password: currentState.password, passwordCheck: currentState.passwordCheck)
            return .merge(
                .just(Mutation.phoneNumberValue(value)),
                .just(Mutation.setSignUpButtonEnabled(isEnabled))
            )
            
        case .inputPassword(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: value, passwordCheck: currentState.passwordCheck)
            return .merge(
                .just(Mutation.passwordValue(value)),
                .just(Mutation.setSignUpButtonEnabled(isEnabled))
            )
            
        case .inputPasswordCheck(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: value)
            return .concat(
                .just(Mutation.passwordCheckValue(value)),
                .just(Mutation.setSignUpButtonEnabled(isEnabled))
            )
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
            
        case .setEmailDuplicateStatus(let value):
            newState.isEmailDuplicateCheckPassed = value
            
        case .setEmailValid(let value):
            newState.isEmailValid = value
            
        case .toastMessageValue(let value):
            newState.toastMessage = value
            
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setNicknameValid(let value):
            newState.isNicknameValid = value
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
    
    //이메일 형식 유효성 검사
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    //이메일 중복 체크
    private func checkEmailDuplication(email: String) -> Observable<Mutation> {
        return NetworkManager.shared.checkEmailDuplication(email: email)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success:
                    return .concat([
                        .just(.setEmailDuplicateStatus(true)),
                        .just(.toastMessageValue("사용 가능한 이메일입니다.")),
                        .just(.toastMessageValue(""))
                    ])
                    
                case .failure(let error):
                    let errorValue = (Router.APIType.emailValidation, error.errorCode)
                    
                    return .concat([
                        .just(.setEmailDuplicateStatus(false)),
                        .just(.setNetworkError(errorValue)),
                        .just(.setNetworkError((Router.APIType.empty, nil)))
                    ])
                }
            }
    }
    
    //닉네임 유효성 검사(닉네임 조건 최소 1글자 최대 30글자)
    private func isValidNickname(nickname: String) -> Bool {
        guard !nickname.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        if nickname.count >= 1 && nickname.count <= 30 {
            return true
        }
        return false
    }
}
