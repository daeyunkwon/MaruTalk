//
//  SectionModel.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/16/24.
//

import Foundation

import RxDataSources

enum SectionItem: Equatable, IdentifiableType {
    case channel(Channel)
    case dm(DMRoom)
    case add(String)
    
    // IdentifiableType의 요구사항
    var identity: String {
        switch self {
        case .channel(let channel):
            return "channel-\(channel.id)"
        
        case .dm(let dm):
            return "dm-\(dm.roomID)"
        
        case .add(let value):
            return "add-\(value)"
        }
    }
    
    static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
        switch (lhs, rhs) {
        case let (.channel(lhsChannel), .channel(rhsChannel)):
            return lhsChannel.id == rhsChannel.id && lhsChannel.unreadCount == rhsChannel.unreadCount && lhsChannel.name == rhsChannel.name
        
        case let (.dm(lhsDM), .dm(rhsDM)):
            return lhsDM.roomID == rhsDM.roomID && lhsDM.user.nickname == rhsDM.user.nickname && lhsDM.user.profileImage == rhsDM.user.profileImage
        
        case let (.add(lhsValue), .add(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

struct SectionModel: AnimatableSectionModelType, IdentifiableType, Equatable {
    typealias Item = SectionItem
    
    var id: String
    var headerTitle: String
    var items: [SectionItem]
    var isExpanded: Bool
    var index: Int
    
    // IdentifiableType의 요구사항
    var identity: String {
        return id
    }
    
    // Equatable 비교를 위한 구현
    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.headerTitle == rhs.headerTitle &&
               lhs.items == rhs.items &&
               lhs.isExpanded == rhs.isExpanded &&
               lhs.index == rhs.index
    }
    
    // AnimatableSectionModelType의 요구사항
    init(original: SectionModel, items: [SectionItem]) {
        self = original
        self.items = items
    }
}

extension SectionModel {
    init(headerTitle: String, items: [SectionItem], index: Int, isExpanded: Bool = false) {
        self.id = UUID().uuidString
        self.headerTitle = headerTitle
        self.items = items
        self.isExpanded = isExpanded
        self.index = index
    }
}


