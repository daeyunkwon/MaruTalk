//
//  ProfileCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/12/24.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)?
    var navigationController: UINavigationController
    
    var onLogout: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("DEBUG: \(String(describing: self)) deinit")
    }
    
    func start() {
        let reactor = ProfileReactor()
        let profileVC = ProfileViewController(reactor: reactor)
        profileVC.coordinator = self
        navigationController.pushViewController(profileVC, animated: true)
    }
    
    func didFinish(isNavigateToOnboarding: Bool = false) {
        
        if isNavigateToOnboarding {
            onLogout?()
        }
        
        parentCoordinator?.removeCoordinator(child: self)
        navigationController.popViewController(animated: true)
    }
}
