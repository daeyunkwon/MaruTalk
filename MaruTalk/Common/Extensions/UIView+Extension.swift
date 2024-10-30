//
//  UIView+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}

