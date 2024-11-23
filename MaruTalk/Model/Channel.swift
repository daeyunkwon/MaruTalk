//
//  Channel.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/22/24.
//

import Foundation

struct Channel: Decodable {
    let id: String
    let name: String
    let description: String?
    let coverImage: String?
    let ownerID: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "channel_id"
        case name
        case description
        case coverImage
        case ownerID = "owner_id"
        case createdAt
    }
}
