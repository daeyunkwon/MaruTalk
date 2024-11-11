//
//  OnboardingCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

final class OnboardingCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.coordinator = self
        navigationController.pushViewController(onboardingVC, animated: true)
    }
}

extension OnboardingCoordinator {
    func showAuth() {
        let authVC = AuthViewController()
        authVC.coordinator = self
        
        //AuthVC Sheet 설정
        if let sheet = authVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 260 }]
            sheet.prefersGrabberVisible = true
        }
        
        //배경 어둡게 설정
        let backgroundView = UIView(frame: navigationController.view.bounds)
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.0
        navigationController.view.addSubview(backgroundView)
        
        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = 0.5
        }
        
        navigationController.present(authVC, animated: true)
    }
    
    func didFinishAuth() {
        navigationController.dismiss(animated: true)
        
        //어두운 배경 제거
        navigationController.view.subviews.forEach({ subview in
            if subview.backgroundColor == UIColor.black {
                
                subview.alpha = 0.5
                
                UIView.animate(withDuration: 0.3) {
                    subview.alpha = 0.0
                } completion: { _ in
                    subview.removeFromSuperview()
                }
            }
        })
    }
}

extension OnboardingCoordinator {
    func showSignUp() {
        let signUpVC = SignUpViewController()
        signUpVC.coordinator = self
        navigationController.pushViewController(signUpVC, animated: true)
    }
    
    func didFinishSignUp() {
        navigationController.popViewController(animated: true)
    }
}
