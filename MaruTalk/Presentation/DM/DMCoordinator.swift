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
    var viewController: DMViewController
    
    init(navigationController: UINavigationController, viewController: DMViewController) {
        self.navigationController = navigationController
        self.viewController = viewController
    }
    
    func start() {
        
    }
}
