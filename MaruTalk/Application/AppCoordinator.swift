//
//  AppCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    var window: UIWindow
    
    private var isLoggedIn: Bool
    
    init(window: UIWindow, navigationController: UINavigationController, isLoggedIn: Bool) {
        self.window = window
        self.navigationController = navigationController
        self.isLoggedIn = isLoggedIn
    }
    
    func start() {
        if isLoggedIn {
            showMainTabBar()
        } else {
            showOnboarding()
        }
    }
}

extension AppCoordinator {
    func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        
        onboardingCoordinator.parentCoordinator = self
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
        
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = scene.window {
            window.rootViewController = navigationController
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        }
    }
}

extension AppCoordinator {
    func showMainTabBar() {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        
        mainTabBarCoordinator.parentCoordinator = self
        childCoordinators.append(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
    }
}
