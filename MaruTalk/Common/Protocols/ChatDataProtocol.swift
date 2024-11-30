//
//  ChatDataProtocol.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import Foundation

import RealmSwift

protocol ChatDataProtocol {
    var user: RealmUser? { get }
    var content: String { get }
    var files: List<String> { get }
    var createdAt: Date { get }
}
