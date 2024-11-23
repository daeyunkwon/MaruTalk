//
//  DMS.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/23/24.
//

import Foundation

struct DMS: Decodable, Equatable {
    let roomID: String
    let createAt: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createAt
        case user
    }
    
    static func == (lhs: DMS, rhs: DMS) -> Bool {
        lhs.roomID == rhs.roomID
    }
}
