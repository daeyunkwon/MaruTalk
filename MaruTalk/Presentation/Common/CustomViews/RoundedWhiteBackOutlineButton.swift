//
//  RoundedWhiteBackOutlineButton.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import UIKit

final class RoundedWhiteBackOutlineButton: UIButton {
    
    init(title: String, color: UIColor = Constant.Color.brandBlack) {
        super.init(frame: .zero)
        configure(title: title, color: color)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String, color: UIColor) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = Constant.Font.title2
        self.setBackgroundColor(Constant.Color.brandWhite, for: .normal)
        self.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
    }
}
