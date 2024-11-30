//
//  RealmChat.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import Foundation

import RealmSwift

final class RealmChannelChat: Object, ChatDataProtocol {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var channelID: String
    @Persisted var channelName: String
    @Persisted var content: String
    @Persisted var createdAt: Date
    @Persisted var files: List<String>
    @Persisted var user: RealmUser? // User 객체와 연결
    
    convenience init(chat: Chat) {
        self.init()
        self.chatID = chat.chatID ?? ""
        self.channelID = chat.channelID ?? ""
        self.content = chat.content
        self.createdAt = Date.createdDate(dateString: chat.createdAt)
        self.channelName = chat.channelName ?? ""
        
        if let files = chat.files {
            self.files.append(objectsIn: files)
        } else {
            self.files = List<String>() //빈 배열로 정의됨
        }
        
        self.user = RealmUser(user: chat.user)
    }
    
    enum Key: String {
        case chatID
        case channelID
        case channelName
        case content
        case createdAt
        case files
        case user
    }
}
