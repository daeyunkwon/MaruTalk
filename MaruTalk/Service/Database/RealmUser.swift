//
//  RealmUser.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import Foundation

import RealmSwift

final class RealmUser: Object {
    @Persisted(primaryKey: true) var userID: String
    @Persisted var email: String
    @Persisted var nickname: String
    @Persisted var profileImage: String?
    
    convenience init(user: User) {
        self.init()
        self.userID = user.userID
        self.email = user.email
        self.nickname = user.nickname
        self.profileImage = user.profileImage
    }
    
    enum Key: String {
        case userID
        case email
        case nickname
        case profileImage
    }
}

