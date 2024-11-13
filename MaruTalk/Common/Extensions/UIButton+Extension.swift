//
//  UIButton+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/30/24.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(backgroundImage, for: state)
    }
    
    func setButtonEnabled(isEnabled: Bool) {
        if isEnabled {
            setBackgroundColor(Constant.Color.brandGreen, for: .normal)
            self.isUserInteractionEnabled = true
        } else {
            setBackgroundColor(Constant.Color.brandInactive, for: .normal)
            self.isUserInteractionEnabled = false
        }
    }
}
