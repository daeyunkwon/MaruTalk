//
//  RectangleBrandColorButton.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/30/24.
//

import UIKit

final class RectangleBrandColorButton: UIButton {
    
    init(title: String, backgroundColor: UIColor = Constant.Color.brandGreen) {
        super.init(frame: .zero)
        configure(title: title, backgroundColor: backgroundColor)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String, backgroundColor: UIColor) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(Constant.Color.brandWhite, for: .normal)
        self.titleLabel?.font = Constant.Font.title2
        self.setBackgroundColor(backgroundColor, for: .normal)
        self.setBackgroundColor(backgroundColor.withAlphaComponent(0.5), for: .highlighted)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
}

