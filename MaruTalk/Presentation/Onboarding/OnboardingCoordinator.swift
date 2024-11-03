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
        navigationController.navigationBar.isHidden = true
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
        let chlid = AuthCoordinator(navigationController: navigationController)
        self.childCoordinators.append(chlid)
        chlid.parentCoordinator = self
        chlid.start()
    }
}
