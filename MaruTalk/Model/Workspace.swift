//
//  Workspace.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/18/24.
//

import Foundation

struct Workspace: Decodable {
    let id: String
    let name: String
    let description: String
    let coverImage: String?
    let owner_id: String
    let createdAt: String
    
    var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self.createdAt) ?? Date()
    }
}