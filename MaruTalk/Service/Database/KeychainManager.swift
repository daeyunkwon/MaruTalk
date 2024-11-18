//
//  KeychainManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/11/24.
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    private init() {}
    
    enum KeyType: String {
        case accessToken
        case refreshToken
    }
    
    func saveToken(token: String, forKey key: KeyType) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data] as CFDictionary
        
        SecItemDelete(query) //Keychain은 Key값에 중복이 생기면 저장할 수 없기 때문에 먼저 Delete
        let status = SecItemAdd(query, nil)
        
        if status == errSecSuccess {
            print("DEBUG: 키체인을 이용해 토큰 저장 성공")
        } else {
            print("DEBUG: 키체인을 이용해 토큰 저장 실패")
            print(SecCopyErrorMessageString(status, nil) ?? "")
        }
        
        return status == errSecSuccess
    }
    
    func getToken(forKey key: KeyType) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data else {
            print(SecCopyErrorMessageString(status, nil) ?? "")
            print("DEBUG: 키체인에 저장된 토큰 없음")
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken(forKey key: KeyType) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue] as CFDictionary
        
        let status = SecItemDelete(query)
        
        if status == errSecSuccess {
            print("DEBUG: 키체인에 저장된 토큰 삭제 성공")
        } else {
            print("DEBUG: 키체인에 저장된 토큰 삭제 실패")
            print(SecCopyErrorMessageString(status, nil) ?? "")
        }
        
        return status == errSecSuccess
    }
}
