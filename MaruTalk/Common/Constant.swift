//
//  Constant.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

enum Constant {
    enum Color {
        static let brandGreen: UIColor = UIColor(red: 74/255, green: 198/255, blue: 68/255, alpha: 1.0)
        static let brandRed: UIColor = UIColor(red: 233/255, green: 102/255, blue: 107/255, alpha: 1.0)
        static let brandInactive: UIColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
        static let brandBlack: UIColor = .black
        static let brandGray: UIColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
        static let brandWhite: UIColor = .white
        
        static let textPrimary: UIColor = .black
        static let textSecondary: UIColor = UIColor(red: 97/255, green: 96/255, blue: 96/255, alpha: 1.0)
        
        static let backgroundPrimary: UIColor = UIColor(red: 246/255, green: 247/255, blue: 246/255, alpha: 1.0)
        static let backgroundSecondary: UIColor = .white
        
        static let viewSeparator: UIColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
        static let viewAlpha: UIColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
    }
    
    enum Font {
        static let title1: (UIFont, CGFloat) = (.systemFont(ofSize: 22, weight: .bold), 30)
        static let title2: (UIFont, CGFloat) = (.systemFont(ofSize: 14, weight: .bold), 20)
        static let bodyBold: (UIFont, CGFloat) = (.systemFont(ofSize: 13, weight: .bold), 18)
        static let body: (UIFont, CGFloat) = (.systemFont(ofSize: 13, weight: .regular), 18)
        static let caption: (UIFont, CGFloat) = (.systemFont(ofSize: 12, weight: .regular), 18)
    }
}
