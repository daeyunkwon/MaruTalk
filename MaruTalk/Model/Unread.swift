//
//  Unread.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import Foundation

struct Unread: Decodable {
    let roomID: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case count
    }
}