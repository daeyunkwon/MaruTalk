//
//  SignUpReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/3/24.
//

import Foundation

import ReactorKit

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
        case signUpButtonTapped
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
        case setPhoneNumberValid(Bool)
        case setPasswordValid(Bool)
        case setPasswordCheckValid(Bool)
        
        case setSignUpInProgress(Bool)
        case setValidationStates([Bool])
        case setSignUpSuccess(Bool)
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
        var isPhoneNumberValid = false
        var isPasswordValid = false
        var isPasswordCheckValid = false
        
        @Pulse var toastMessage: (String) = ""
        var networkError: (Router.APIType, String?) = (Router.APIType.empty, nil)
        
        var validationStates: [Bool] = []
        var isSignUpInProgress = false
        var isSignUpSuccess = false
        
        var isFormValid: Bool {
            return isEmailDuplicateCheckPassed && isEmailValid && isNicknameValid && isPhoneNumberValid && isPasswordValid && isPasswordCheckValid
        }
    }
    
    let initialState: State = State()
}

//MARK: - Mutate

extension SignUpReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .closeButtonTapped:
            return .just(.close)
            
        case .inputEmail(let value):
            let isEmailCheckButtonEnabled = isEmailDuplicateCheckButtonEnabled(email: value)
            let isEnabled = isSignUpButtonEnabled(email: value, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: currentState.passwordCheck)
            let isValid = isValidEmail(email: value)
            var isPassed = false
            
            if currentState.isEmailDuplicateCheckPassed && value == currentState.email {
                isPassed = true
            }
            
            return Observable.concat([
                .just(Mutation.emailValue(value)),
                .just(.setEmailDuplicateCheckButtonEnabled(isEmailCheckButtonEnabled)),
                .just(.setSignUpButtonEnabled(isEnabled)),
                .just(.setEmailDuplicateStatus(isPassed)),
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
                        .just(.toastMessageValue("사용 가능한 이메일입니다."))
                    ])
                }
            } else {
                return .concat([
                    .just(.toastMessageValue("이메일 형식이 올바르지 않습니다."))
                ])
            }
            
        case .inputNickname(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: value, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: currentState.passwordCheck)
            let isValid = isValidNickname(nickname: value)
            
            return .merge(
                .just(.nicknameValue(value)),
                .just(.setSignUpButtonEnabled(isEnabled)),
                .just(.setNicknameValid(isValid))
            )
            
        case .inputPhoneNumber(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: value, password: currentState.password, passwordCheck: currentState.passwordCheck)
            let isValid = isValidPhoneNumber(phoneNumber: value)
            let formatValue = formatPhoneNumber(phoneNumber: value)
            
            return .merge(
                .just(.phoneNumberValue(formatValue)),
                .just(.setSignUpButtonEnabled(isEnabled)),
                .just(.setPhoneNumberValid(isValid))
            )
            
        case .inputPassword(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: value, passwordCheck: currentState.passwordCheck)
            let isValid = isValidPassword(password: value)
            
            return .merge(
                .just(.passwordValue(value)),
                .just(.setSignUpButtonEnabled(isEnabled)),
                .just(.setPasswordValid(isValid))
            )
            
        case .inputPasswordCheck(let value):
            let isEnabled = isSignUpButtonEnabled(email: currentState.email, nickname: currentState.nickname, phoneNumber: currentState.phoneNumber, password: currentState.password, passwordCheck: value)
            let isValid = isValidPasswordCheck(password: currentState.password, passwordCheck: value)
            
            return .concat(
                .just(.passwordCheckValue(value)),
                .just(.setSignUpButtonEnabled(isEnabled)),
                .just(.setPasswordCheckValid(isValid))
            )
            
        case .signUpButtonTapped:
            let stateList = [currentState.isEmailDuplicateCheckPassed, currentState.isNicknameValid, currentState.isPhoneNumberValid, currentState.isPasswordValid, currentState.isPasswordCheckValid]
            
            return .concat(
                .just(.setValidationStates(stateList)),
                .just(.setSignUpInProgress(true)),
                currentState.isFormValid ? performSignUp(email: currentState.email, password: currentState.password, nickname: currentState.nickname, phone: currentState.phoneNumber, deviceToken: "") : .empty(),
                .just(.setSignUpInProgress(false))
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
            
        case .setNicknameValid(let value):
            newState.isNicknameValid = value
            
        case .setPhoneNumberValid(let value):
            newState.isPhoneNumberValid = value
            
        case .setPasswordValid(let value):
            newState.isPasswordValid = value
            
        case .setPasswordCheckValid(let value):
            newState.isPasswordCheckValid = value
            
        case .setValidationStates(let value):
            newState.validationStates = value
            
        case .setSignUpInProgress(let value):
            newState.isSignUpInProgress = value
            
        case .setSignUpSuccess(let value):
            newState.isSignUpSuccess = value
            
        case .toastMessageValue(let value):
            newState.toastMessage = value
            
        case .setNetworkError(let value):
            newState.networkError = value
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
    
    //전화번호 유효성 검사
    private func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let numberRegEx = "[0]+[1]+[0-9]{8,9}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        return numberTest.evaluate(with: digits)
    }
    
    //전화번호 표시 형식 변환
    private func formatPhoneNumber(phoneNumber: String) -> String {
        var digits = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let digitsCount = digits.count //하이픈 없이 숫자만 있는 개수
        
        if digitsCount > 3 {
            let startIndex = digits.startIndex
            digits.insert("-", at: digits.index(startIndex, offsetBy: 3))
            
            if digitsCount > 6 {
                digits.insert("-", at: digits.index(startIndex, offsetBy: 6 + 1))
            }
            
            if digitsCount > 10 {
                digits.remove(at: digits.index(startIndex, offsetBy: 6 + 1))
                digits.insert("-", at: digits.index(startIndex, offsetBy: 7 + 1))
            }
            
            return digits
        }
        
        return phoneNumber //아무 작업없이 그대로 반환
    }
    
    //비밀번호 유효성 검사
    private func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!_@$%^&+=-])[A-Z0-9a-z.!_@$%^&+=-]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    //비밀번호 확인 유효성 검사
    private func isValidPasswordCheck(password: String, passwordCheck: String) -> Bool {
        guard !passwordCheck.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        return password == passwordCheck ? true : false
    }
    
    //회원가입
    private func performSignUp(email: String, password: String, nickname: String, phone: String, deviceToken: String) -> Observable<Mutation> {
        return NetworkManager.shared.performRequest(
            api: .join(
                email: email,
                password: password,
                nickname: nickname,
                phone: phone,
                deviceToken: deviceToken
            ),
            model: User.self
        ).asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    print("DEBUG: 회원가입 성공 응답값:\n\(value)")
                    
                    let isAccessTokenSaved = KeychainManager.shared.saveToken(token: value.token.accessToken, forKey: .accessToken)
                    let isRefreshTokenSaved = KeychainManager.shared.saveToken(token: value.token.refreshToken, forKey: .refreshToken)
                    
                    //토큰 저장 실패 시 로그인 유도
                    return isAccessTokenSaved && isRefreshTokenSaved ? .just(.setSignUpSuccess(true)).delay(.seconds(1), scheduler: MainScheduler.instance) : .just(.toastMessageValue("가입성공! 로그인을 진행해주세요!"))
                    
                case .failure(let error):
                    let errorValue = (Router.APIType.join, error.errorCode)
                    
                    return .concat([
                        .just(.setSignUpSuccess(false)),
                        .just(.setNetworkError(errorValue)),
                        .just(.setNetworkError((Router.APIType.empty, nil)))
                    ])
                }
            }
    }
}
