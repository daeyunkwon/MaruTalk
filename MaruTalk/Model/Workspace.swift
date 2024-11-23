//
//  Workspace.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/21/24.
//

import Foundation

struct Workspace: Decodable {
    let id: String
    let name: String
    let description: String?
    let coverImage: String?
    let ownerID: String
    let createdAt: String
    let channels: [Channel]?
    let workspaceMembers: [WorkspaceMember]?
    
    enum CodingKeys: String, CodingKey {
        case id = "workspace_id"
        case name
        case description
        case coverImage
        case ownerID = "owner_id"
        case createdAt
        case channels
        case workspaceMembers
    }
}

struct WorkspaceMember: Decodable {
    let userID: String
    let email: String
    let nickname: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nickname
        case profileImage
    }
}


