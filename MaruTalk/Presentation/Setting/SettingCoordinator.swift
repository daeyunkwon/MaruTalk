//
//  SettingCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

final class SettingCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    var parentCoordinator: (any Coordinator)?
    var viewController: SettingViewController
    
    init(navigationController: UINavigationController, viewController: SettingViewController) {
        self.navigationController = navigationController
        self.viewController = viewController
    }
    
    func start() {
        
    }
}
