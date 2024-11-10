//
//  User.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/10/24.
//

import Foundation

struct User: Decodable {
    let userId: String
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let provider: String?
    let createdAt: Date
    let token: Token
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nickname
        case profileImage
        case phone
        case provider
        case createdAt
        case token
    }
}

struct Token: Decodable {
    let accessToken: String
    let refreshToken: String
}
