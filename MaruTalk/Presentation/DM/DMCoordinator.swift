//
//  DMCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

final class DMCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    var parentCoordinator: (any Coordinator)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let dmVC = DMViewController()
        dmVC.coordinator = self
        navigationController.pushViewController(dmVC, animated: true)
    }
}
