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
    
    private var isLoggedIn: Bool
    
    init(navigationController: UINavigationController, isLoggedIn: Bool) {
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
    }
}

extension AppCoordinator {
    func showMainTabBar() {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        
        mainTabBarCoordinator.parentCoordinator = self
        childCoordinators.append(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
        
        navigationController.viewControllers = [mainTabBarCoordinator.tabBarController]
    }
}
