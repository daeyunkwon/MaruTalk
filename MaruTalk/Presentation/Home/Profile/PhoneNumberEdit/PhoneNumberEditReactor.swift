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
    }
    
    enum Mutation {
        case setDoneButtonEnabled(Bool)
        case setNewPhoneNumber(String)
    }
    
    struct State {
        var user: User
        var newPhoneNumber: String
        @Pulse var placeholderText: String = "연락처를 입력해주세요."
        var isDoneButtonEnabled: Bool = true
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
}
