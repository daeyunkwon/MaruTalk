//
//  UIViewController+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import UIKit

extension UIViewController {
    func showAlertForNetworkError(api: Router, errorCode: String?) {
        
        var message: String = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        
        guard let errorCode = errorCode else {
            let alert = UIAlertController(title: "시스템 오류 알림", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        
        switch api {
        case .emailValidation(_):
            switch errorCode {
            case "E11": message = "이메일 형식이 올바르지 않습니다."
            case "E12": message = "이미 사용중인 이메일 주소입니다."
            default: break
            }
        }
        
        
        
        
        
        let alert = UIAlertController(title: "시스템 오류 알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
}
