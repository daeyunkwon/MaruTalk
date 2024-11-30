//
//  RealmDMChat.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import Foundation

import RealmSwift

final class RealmDMChat: Object {
    @Persisted(primaryKey: true) var dmID: String
    @Persisted var roomID: String
    @Persisted var content: String
    @Persisted var createdAt: Date
    @Persisted var files: List<String>
    @Persisted var user: RealmUser? // User 객체와 연결
    
    convenience init(chat: Chat) {
        self.init()
        self.dmID = chat.dmID ?? ""
        self.roomID = chat.roomID ?? ""
        self.content = chat.content
        self.createdAt = Date.createdDate(dateString: chat.createdAt)
        
        if let files = chat.files {
            self.files.append(objectsIn: files)
        } else {
            self.files = List<String>() //빈 배열로 정의됨
        }
        
        self.user = RealmUser(user: chat.user)
    }
    
    enum Key: String {
        case dmID
        case roomID
        case content
        case createdAt
        case files
        case user
    }
}
