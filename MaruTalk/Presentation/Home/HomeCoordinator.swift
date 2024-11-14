//
//  HomeCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

final class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    var viewController: HomeViewController
    
    init(navigationController: UINavigationController, viewController: HomeViewController) {
        self.navigationController = navigationController
        self.viewController = viewController
    }
    
    deinit {
        print("DEBUG: HomeCoordinator deinit")
    }
    
    func start() {
        viewController.coordinator = self
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        if let mainTabBarCoordinator = parentCoordinator as? MainTabBarCoordinator {
            mainTabBarCoordinator.didFinish()
        }
    }
}
