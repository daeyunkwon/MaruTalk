//
//  User.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/10/24.
//

import Foundation

struct User: Decodable {
    let userID: String
    let email: String
    var nickname: String
    let profileImage: String?
    var phone: String?
    let provider: String?
    let createdAt: String?
    let token: Token?
    let sesacCoin: Int?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nickname
        case profileImage
        case phone
        case provider
        case createdAt
        case token
        case sesacCoin
    }
}

struct Token: Decodable {
    let accessToken: String
    let refreshToken: String
}
