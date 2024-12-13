//
//  PhoneNumberEditReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/13/24.
//

import Foundation

import ReactorKit

final class PhoneNumberEditReactor: Reactor {
    enum Action {
        case inputPhoneNumber(String)
        case doneButtonTapped
    }
    
    enum Mutation {
        case setDoneButtonEnabled(Bool)
        case setNewPhoneNumber(String)
        case setNetworkError((Router.APIType, String?))
        case setNavigateToProfile
    }
    
    struct State {
        var user: User
        var newPhoneNumber: String
        @Pulse var placeholderText: String = "연락처를 입력해주세요."
        var isDoneButtonEnabled: Bool = true
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var navigateToProfile: Void?
    }
    
    let initialState: State
    
    init(user: User) {
        self.initialState = State(user: user, newPhoneNumber: user.phone ?? "")
    }
}

//MARK: - Mutate

extension PhoneNumberEditReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputPhoneNumber(let value):
            let phoneNumberWithDash = transformPhoneNumberWithDash(phoneNumber: value)
            let isValid = isPhoneNumberValid(phoneNumber: phoneNumberWithDash)
            
            return .concat([
                .just(.setNewPhoneNumber(phoneNumberWithDash)),
                .just(.setDoneButtonEnabled(isValid))
            ])
            
        case .doneButtonTapped:
            //변경사항이 없는 경우 네트워크 통신 작업없이 이전 프로필 화면으로 돌아가기
            if currentState.user.phone ?? "" == currentState.newPhoneNumber {
                return .just(.setNavigateToProfile)
            } else {
                return executePhoneNumberEdit()
            }
        }
    }
}

//MARK: - Reduce

extension PhoneNumberEditReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDoneButtonEnabled(let value):
            newState.isDoneButtonEnabled = value
            
        case .setNewPhoneNumber(let value):
            newState.newPhoneNumber = value
            
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setNavigateToProfile:
            newState.navigateToProfile = ()
        }
        return newState
    }
}

//MARK: - Logic

extension PhoneNumberEditReactor {
    private func transformPhoneNumberWithDash(phoneNumber: String) -> String {
        var replaceString = phoneNumber.replacingOccurrences(of: "-", with: "")
        let count = replaceString.count
        
        if count >= 4 {
            if count >= 7 && count < 11 {
                replaceString.insert("-", at: replaceString.index(replaceString.startIndex, offsetBy: 6))
            } else if count >= 11 {
                replaceString.insert("-", at: replaceString.index(replaceString.startIndex, offsetBy: 7))
            }
            replaceString.insert("-", at: replaceString.index(replaceString.startIndex, offsetBy: 3))
        }
        return replaceString
    }
    
    private func isPhoneNumberValid(phoneNumber: String) -> Bool {
        let replaceString = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        //10자리 또는 11자리
        guard replaceString.count == 10 || replaceString.count == 11 else {
            return false
        }
        
        //숫자 형식 확인
        guard Int(replaceString) != nil else {
            return false
        }
        
        return true
    }
    
    private func executePhoneNumberEdit() -> Observable<Mutation> {
        let nickname = currentState.user.nickname
        let phone = currentState.newPhoneNumber
        
        return NetworkManager.shared.performRequest(api: .userMeEdit(nickname: nickname, phone: phone), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    NotificationCenter.default.post(name: .profileEditComplete, object: nil, userInfo: [NotificationUserInfoKey.user: value])
                    return .just(.setNavigateToProfile)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMeEdit, error.errorCode)))
                }
            }
    }
}
