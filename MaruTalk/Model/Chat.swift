//
//  Chat.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import Foundation

struct Chat: Decodable {
    let channelID: String?
    let channelName: String?
    let chatID: String?
    
    let dmID: String?
    let roomID: String?
    
    let content: String
    let createdAt: String
    let files: [String]?
    var user: User
    
    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case channelName
        case chatID = "chat_id"
        case dmID = "dm_id"
        case roomID = "room_id"
        case content
        case createdAt
        case files
        case user
    }
}
