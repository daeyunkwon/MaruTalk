//
//  DMRoom.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/23/24.
//

import Foundation

struct DMRoom: Decodable, Equatable {
    let roomID: String
    let createdAt: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt
        case user
    }
    
    static func == (lhs: DMRoom, rhs: DMRoom) -> Bool {
        lhs.roomID == rhs.roomID
    }
}
