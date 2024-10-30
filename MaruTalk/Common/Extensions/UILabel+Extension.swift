//
//  UILabel+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

extension  UILabel {
    
    func setTextFontWithLineHeight(text: String?, font: UIFont, lineHeight: CGFloat) {
        if let text = text {
            self.font = font
            let style = NSMutableParagraphStyle()
            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: style,
                .baselineOffset: (lineHeight - self.font.lineHeight) / 2
            ]
            
            let attrString = NSAttributedString(string: text, attributes: attributes)
            self.attributedText = attrString
        }
    }
}
