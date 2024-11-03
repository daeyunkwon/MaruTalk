//
//  SignUpCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

final class SignUpCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("SignUpCoordinator deinit")
    }
    
    func start() {
        let signUpVC = SignUpViewController()
        signUpVC.coordinator = self
        navigationController.pushViewController(signUpVC, animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        navigationController.popViewController(animated: true)
    }
}
