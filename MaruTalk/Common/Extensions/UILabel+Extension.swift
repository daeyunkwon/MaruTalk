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
    
    func setTimeString(date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        
        // 날짜가 오늘이면 시간만 표시, 아니면 날짜와 시간 모두 표시
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "a hh:mm" // "오전 08:33"
        } else {
            formatter.dateFormat = "M/d a hh:mm" // "1/12 오전 08:32"
        }
        
        self.text = formatter.string(from: date)
    }
}
