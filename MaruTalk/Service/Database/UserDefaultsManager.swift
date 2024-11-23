//
//  UserDefaultsManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/18/24.
//

import UIKit

@propertyWrapper
struct UserDefaultsPropertyWrapper<T> {
    let key: String
    let defaultValue: T
    var storage: UserDefaults
    
    var wrappedValue: T {
        get {
            return self.storage.object(forKey: self.key) as? T ?? self.defaultValue
        }
        set {
            return self.storage.set(newValue, forKey: self.key)
        }
    }
}

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private init() {}
    
    enum Key: String {
        case recentWorkspaceID
        case recentWorkspaceOwnerID
        case userID
    }
    
    @UserDefaultsPropertyWrapper(key: Key.recentWorkspaceID.rawValue, defaultValue: nil, storage: UserDefaults.standard)
    var recentWorkspaceID: String?
    
    @UserDefaultsPropertyWrapper(key: Key.recentWorkspaceOwnerID.rawValue, defaultValue: nil, storage: UserDefaults.standard)
    var recentWorkspaceOwnerID: String?
    
    @UserDefaultsPropertyWrapper(key: Key.userID.rawValue, defaultValue: nil, storage: UserDefaults.standard)
    var userID: String?
    
    
    func removeItem(key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
