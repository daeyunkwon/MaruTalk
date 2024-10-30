//
//  Reusable.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension UIView: Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
