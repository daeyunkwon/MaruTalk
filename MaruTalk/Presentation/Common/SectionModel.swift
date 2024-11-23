//
//  SectionModel.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/16/24.
//

import Foundation

import RxDataSources

//enum SectionItem: Equatable {
//    case channel(String)
//    case dm(String)
//    
//    static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
//        switch (lhs, rhs) {
//        case let (.channel(lhsValue), .channel(rhsValue)):
//            return lhsValue == rhsValue
//        case let (.dm(lhsValue), .dm(rhsValue)):
//            return lhsValue == rhsValue
//        default:
//            return false
//        }
//    }
//}

//struct SectionModel: Equatable, Identifiable {
//    var id = UUID().uuidString
//    var headerTitle: String
//    var items: [SectionItem]
//    var isExpanded: Bool = false
//    var index: Int
//    
//    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
//        return lhs.id == rhs.id &&
//               lhs.headerTitle == rhs.headerTitle &&
//               lhs.items == rhs.items
//    }
//}
//
//extension SectionModel: SectionModelType {
//    typealias Item = SectionItem
//    
//    init(original: SectionModel, items: [SectionItem]) {
//        self = original
//        self.items = items
//    }
//}


enum SectionItem: Equatable, IdentifiableType {
    case channel(Channel)
    case dm(DMS)
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
            return lhsChannel == rhsChannel
        case let (.dm(lhsDM), .dm(rhsDM)):
            return lhsDM == rhsDM
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


