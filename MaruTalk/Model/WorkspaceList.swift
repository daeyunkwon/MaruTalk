//
//  Workspace.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/18/24.
//

import Foundation

struct WorkspaceList: Decodable {
    let id: String
    let name: String
    let description: String?
    let coverImage: String?
    let ownerID: String
    let createdAt: String
    
    var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self.createdAt) ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "workspace_id"
        case name
        case description
        case coverImage
        case ownerID = "owner_id"
        case createdAt
    }
}
