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
    
    deinit {
        print("DEBUG: OnboardingCoordinator deinit")
    }
    
    func start() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.coordinator = self
        navigationController.setViewControllers([onboardingVC], animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        if let appCoordinator = parentCoordinator as? AppCoordinator {
            appCoordinator.showMainTabBar()
        }
    }
}

extension OnboardingCoordinator {
    func showAuth() {
        let reactor = AuthReactor()
        let authVC = AuthViewController(reactor: reactor)
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
    func showLogin() {
        let reactor = LoginReactor()
        let loginVC = LoginViewController(reactor: reactor)
        loginVC.coordinator = self
        
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(navController, animated: true)
    }
    
    func didFinishLogin() {
        navigationController.dismiss(animated: true)
    }
}

extension OnboardingCoordinator {
    func showSignUp() {
        let reactor = SignUpReactor()
        let signUpVC = SignUpViewController(reactor: reactor)
        signUpVC.coordinator = self
        navigationController.pushViewController(signUpVC, animated: true)
    }
    
    func didFinishSignUp() {
        navigationController.popViewController(animated: true)
    }
}

extension OnboardingCoordinator {
    func showWorkspaceInitial(nickname: String) {
        let reactor = WorkspaceInitialReactor(nickname: nickname)
        let workspaceInitialVC = WorkspaceInitialViewController(reactor: reactor)
        workspaceInitialVC.coordinator = self
        navigationController.navigationBar.isHidden = false
        navigationController.pushViewController(workspaceInitialVC, animated: true)
    }
}

extension OnboardingCoordinator {
    func showWorkspaceAdd() {
        let reactor = WorkspaceAddReactor(previousScreen: .workspaceInitial)
        let workspaceAddVC = WorkspaceAddViewController(reactor: reactor)
        workspaceAddVC.coordinator = self

        let navController = UINavigationController(rootViewController: workspaceAddVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        navigationController.present(navController, animated: true)
    }
}
