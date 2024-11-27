//
//  UIViewController+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import UIKit

import Toast

extension UIViewController {
    //NetworkErrorToast
    func showToastForNetworkError(api: Router.APIType, errorCode: String?) {
        var style = ToastStyle()
        style.backgroundColor = Constant.Color.brandRed
        style.maxHeightPercentage = 36.0
        style.messageAlignment = .center
        style.titleAlignment = .center
        style.cornerRadius = 8
        let x = (view.bounds.width / 2)
        let y: Double = 630
        
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
            
        case .join:
            switch errorCode {
            case "E11": message = "계정 형식이 올바르지 않습니다."
            case "E12": message = "이미 가입된 회원입니다. 로그인을 진행해주세요."
            default: break
            }
            
        case .createWorkspace:
            switch errorCode {
            case "E12": message = "워크스페이스 명은 고유한 데이터로 중복될 수 없습니다."
            default: break
            }
            
        case .login, .loginWithApple, .loginWithKakao:
            switch errorCode {
            case "E03": message = "이메일 또는 비밀번호가 올바르지 않습니다."
            case "E12": message = "이미 회원가입 된 계정입니다."
            default: break
            }
            
        case .createChannel:
            switch errorCode {
            case "E12": message = "워크스페이스에 이미 있는 채널 이름입니다. 다른 이름을 입력해주세요."
            default: break
            }
            
        case .workspaceMemberInvite:
            switch errorCode {
            case "E12": message = "이미 워크스페이스에 소속된 팀원이에요."
            case "E03", "E13", "E11": message = "회원 정보를 찾을 수 없습니다."
            default: break
            }
            
        default: break
        }
        
        if errorCode == "Refresh token expiration" {
            message = "로그인 기간이 만료되어 재 로그인이 필요합니다."
        }
        
        view.makeToast(message, point: CGPoint(x: x, y: y), title: nil, image: nil, style: style) { [weak self] didTap in
            if errorCode == "Refresh token expiration" {
                self?.shouldNavigateToLogin()
            }
        }
    }
    
    func shouldNavigateToLogin() {
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            scene.appCoordinator?.childCoordinators.removeAll()
            scene.appCoordinator?.start()
        }
    }
    
    //Toast
    func showToastMessage(message: String, backgroundColor: UIColor = Constant.Color.brandColor) {
        var style = ToastStyle()
        style.backgroundColor = backgroundColor
        style.maxHeightPercentage = 36.0
        style.messageAlignment = .center
        style.titleAlignment = .center
        style.cornerRadius = 8
        
        let x = (view.bounds.width / 2)
        let y: Double = 630
        view.makeToast(message, point: CGPoint(x: x, y: y), title: nil, image: nil, style: style, completion: nil)
    }
    
    //로딩중
    func showToastActivity(shouldShow: Bool) {
        if shouldShow {
            view.makeToastActivity(.center)
        } else {
            view.hideToastActivity()
        }
    }
    
    //액션시트
    func showActionSheet(actions: [(String, (() -> Void)?)]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for (title, handler) in actions {
            let action = UIAlertAction(title: title, style: .default) { _ in
                handler?()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.present(alert, animated: true)
    }
}
