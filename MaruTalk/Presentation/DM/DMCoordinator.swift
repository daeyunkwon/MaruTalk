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
    weak var parentCoordinator: (any Coordinator)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("DEBUG: \(String(describing: self)) deinit")
    }
    
    func start() {
        let reactor = DMListReactor()
        let dmVC = DMListViewController(reactor: reactor)
        dmVC.coordinator = self
        navigationController.setViewControllers([dmVC], animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        if let mainTabBarCoordinator = parentCoordinator as? MainTabBarCoordinator {
            mainTabBarCoordinator.didFinish()
        }
    }
}

extension DMCoordinator {
    func showDMChatting(roomID: String, otherUserID: String) {
        let reactor = DMChattingReactor(roomID: roomID, otherUserID: otherUserID)
        let dmChattingVC = DMChattingViewController(reactor: reactor)
        dmChattingVC.coordinator = self
        navigationController.pushViewController(dmChattingVC, animated: true)
    }
    
    func didFinishDMChatting() {
        navigationController.popViewController(animated: true)
    }
}

extension DMCoordinator {
    func showProfile() {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        profileCoordinator.parentCoordinator = self
        profileCoordinator.onLogout = { [weak self] in
            self?.didFinish()
        }
        childCoordinators.append(profileCoordinator)
        profileCoordinator.start()
    }
}
