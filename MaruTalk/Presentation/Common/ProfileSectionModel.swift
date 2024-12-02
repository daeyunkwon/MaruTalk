//
//  ProfileSectionModel.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import Foundation

import RxDataSources

struct ProfileSectionModel {
    var header: String
    var items: [Item]
}

extension ProfileSectionModel : AnimatableSectionModelType {
    typealias Item = ProfileSectionItem

    var identity: String {
        return header
    }

    init(original: ProfileSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

struct ProfileSectionItem: Equatable, IdentifiableType {
    var identity: some Hashable {
        return title
    }
    
    var title: String
    var subTitle: String
}
