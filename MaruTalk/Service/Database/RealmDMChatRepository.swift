//
//  RealmDMChatRepository.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import Foundation

import RealmSwift

final class RealmDMChatRepository {
    
    static let shared = RealmDMChatRepository()
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

extension RealmDMChatRepository {
    func fetchChatList(roomID: String) -> [RealmDMChat] {
        do {
            let realm = try getRealm()
            
            let result = realm.objects(RealmDMChat.self).filter("roomID == %@", roomID).sorted(byKeyPath: RealmDMChat.Key.createdAt.rawValue, ascending: true)
            
            return Array(result)
        } catch {
            print("ERROR: RealmChat Fetch Failed")
            print(error)
            return []
        }
    }
    
    func saveChat(chat: RealmDMChat) {
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
    
    func deleteChatList(roomID: String, completion: @escaping (Bool) -> Void) {
        do {
            let realm = try getRealm()
            let targetChatList = realm.objects(RealmDMChat.self).filter("roomID == %@", roomID)
            
            print("삭제 타겟---------------------")
            print("룸 아이디: \(roomID)")
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
