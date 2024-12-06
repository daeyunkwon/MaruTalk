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
            
        case .workspaceMemberInvite:
            switch errorCode {
            case "E12": message = "이미 워크스페이스에 소속된 팀원이에요."
            case "E03", "E13", "E11": message = "회원 정보를 찾을 수 없습니다."
            default: break
            }
            
        case .workspaceEdit:
            switch errorCode {
            case "E12": message = "워크스페이스 이름이 이미 사용중입니다."
            case "E14": message = "워크스페이스 관리자만 워크스페이스를 수정할 수 있습니다."
            default: break
            }
            
        case .workspaceExit:
            switch errorCode {
            case "E15": message = "워크스페이스와 워크스페이스에 속한 채널의 관리자 권한이 있는 경우에는 퇴장을 할 수 없습니다."
            default: break
            }
            
        case .workspaceTransferOwnership:
            switch errorCode {
            case "E14": message = "워크스페이스 관리자만 워크스페이스에 대한 권한을 양도할 수 있습니다."
            default: break
            }
            
        case .workspaceDelete:
            switch errorCode {
            case "E14": message = "워크스페이스 관리자만 워크스페이스를 삭제할 수 있습니다."
            default: break
            }
            
        case .createChannel:
            switch errorCode {
            case "E12": message = "워크스페이스에 이미 있는 채널 이름입니다. 다른 이름을 입력해주세요."
            default: break
            }
            
        case .channelEdit:
            switch errorCode {
            case "E12": message = "워크스페이스에 이미 있는 채널 이름입니다. 다른 이름을 입력해주세요."
            default: break
            }
            
        case .channelExit:
            switch errorCode {
            case "E11": message = "기본 채널은 퇴장이 불가합니다.(일반 채널)"
            case "E15": message = "채널 관리자는 채널에 대한 권한을 양도한 후 퇴장할수 있습니다."
            default: break
            }
            
        case .channelDelete:
            switch errorCode {
            case "E11": message = "기본 채널은 삭제가 불가합니다.(일반 채널)"
            case "E14": message = "채널 관리자만 채널을 삭제할 수 있습니다."
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
    func showActionSheet(actions: [(String, UIAlertAction.Style, (() -> Void)?)]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for (title, style, handler) in actions {
            let action = UIAlertAction(title: title, style: style) { _ in
                handler?()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    //얼럿
    func showAlert(title: String, message: String, actions: [(String, (() -> Void)?)], cancelHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (title, handler) in actions {
            let action = UIAlertAction(title: title, style: .default) { _ in
                handler?()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            cancelHandler?()
        }))
        
        self.present(alert, animated: true)
    }
    
    func showOnlyCloseActionAlert(title: String, message: String, action: (String, (() -> Void)?)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: action.0, style: .cancel, handler: { _ in
            action.1?()
        }))
        
        self.present(alert, animated: true)
    }
}
