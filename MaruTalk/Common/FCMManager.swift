//
//  FCMManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/9/24.
//

import Foundation

final class FCMManager {
    
    static let shared = FCMManager()
    private init() { }
    
    private var fcmToken: String?
}

extension FCMManager {
    func getFCMToken() -> String {
        if let token = self.fcmToken {
            print("DEBUG: FCM 토큰값 불러오기 성공", #function)
            return token
        } else {
            print("ERROR: FCM 토큰값 불러오기 실패", #function)
            return ""
        }
    }
    
    func saveFCMToken(token: String) {
        self.fcmToken = token
    }
    
    func deleteFCMToken() {
        self.fcmToken = nil
    }
}
