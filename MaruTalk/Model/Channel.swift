//
//  Channel.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/22/24.
//

import Foundation

struct Channel: Decodable, Equatable {
    let id: String
    let name: String
    let description: String?
    let coverImage: String?
    let ownerID: String
    let createdAt: String
    let channelMembers: [User]?
    var unreadCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "channel_id"
        case name
        case description
        case coverImage
        case ownerID = "owner_id"
        case createdAt
        case channelMembers
        case unreadCount
    }
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
}
