//
//  RealmRepository.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import Foundation

import RealmSwift

final class RealmRepository {
    
    static let shared = RealmRepository()
    private init() { }
     
    private func getRealm() throws -> Realm {
        do {
            return try Realm()
        } catch {
            print("Failed to initialize Realm: \(error.localizedDescription)")
            throw error
        }
    }
}

extension RealmRepository {
    func fetchChatList(channelID: String) -> [RealmChat] {
        do {
            let realm = try getRealm()
            
            let result = realm.objects(RealmChat.self).filter("channelID == %@", channelID).sorted(byKeyPath: RealmChat.Key.createdAt.rawValue, ascending: true)
            
            return Array(result)
        } catch {
            print("ERROR: RealmChat Fetch Failed")
            print(error)
            return []
        }
    }
    
    func saveChat(chat: RealmChat) {
        do {
            let realm = try getRealm()
            try realm.write {
                realm.add(chat, update: .modified)
                print("DEBUG: RealmChat Save Success")
            }
        } catch {
            print("ERROR: RealmChat Save Failed")
            print(error)
        }
    }
    
    func deleteChatList(channelID: String, completion: @escaping (Bool) -> Void) {
        do {
            let realm = try getRealm()
            let targetChatList = realm.objects(RealmChat.self).filter("channelID == %@", channelID)
            
            print("삭제 타겟---------------------")
            print("채널 아이디: \(channelID)")
            print(targetChatList)
            print("삭제 타겟---------------------")
            
            try realm.write {
                realm.delete(targetChatList)
                print("DEBUG: RealmChat Delete Success")
                completion(true)
            }
        } catch {
            print("ERROR: RealmChat Delete Failed")
            print(error)
            completion(false)
        }
    }
}
