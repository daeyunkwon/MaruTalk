//
//  UIViewController+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import UIKit

import Toast

extension UIViewController {
    //Alert
    func showToastForNetworkError(api: Router.APIType, errorCode: String?) {
        var style = ToastStyle()
        style.backgroundColor = Constant.Color.brandRed
        style.maxHeightPercentage = 36.0
        style.messageAlignment = .center
        style.titleAlignment = .center
        style.cornerRadius = 8
        let x = (view.bounds.width / 2)
        let y: Double = 711
        
        var message: String = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        
        guard let errorCode = errorCode else {
            view.makeToast(message, point: CGPoint(x: x, y: y), title: nil, image: nil, style: style, completion: nil)
            return
        }
        
        switch api {
        case .emailValidation:
            switch errorCode {
            case "E11": message = "이메일 형식이 올바르지 않습니다."
            case "E12": message = "이미 사용중인 이메일 주소입니다."
            default: break
            }
            
        default: break
        }
        
        view.makeToast(message, point: CGPoint(x: x, y: y), title: nil, image: nil, style: style, completion: nil)
    }
    
    //Toast
    func showToastMessage(message: String, backgroundColor: UIColor = Constant.Color.brandGreen) {
        var style = ToastStyle()
        style.backgroundColor = backgroundColor
        style.maxHeightPercentage = 36.0
        style.messageAlignment = .center
        style.titleAlignment = .center
        style.cornerRadius = 8
        
        let x = (view.bounds.width / 2)
        let y: Double = 711
        view.makeToast(message, point: CGPoint(x: x, y: y), title: nil, image: nil, style: style, completion: nil)
    }
}
