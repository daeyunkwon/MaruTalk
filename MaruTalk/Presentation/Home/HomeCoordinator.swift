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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("DEBUG: HomeCoordinator deinit")
    }
    
    func start() {
        let reactor = HomeReactor()
        let homeVC = HomeViewController(reactor: reactor)
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        if let mainTabBarCoordinator = parentCoordinator as? MainTabBarCoordinator {
            mainTabBarCoordinator.didFinish()
        }
    }
}

extension HomeCoordinator {
    func showMemberInvite() {
        let reactor = MemberInviteReactor()
        let memberInviteVC = MemberInviteViewController(reactor: reactor)
        memberInviteVC.coordinator = self

        let navController = UINavigationController(rootViewController: memberInviteVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(navController, animated: true)
    }
    
    func didFinishMemberInvite() {
        navigationController.dismiss(animated: true)
    }
}

extension HomeCoordinator {
    func showChannelAdd() {
        let coordinator = ChannelCoordinator(navigationController: navigationController, initialScreen: .channelAdd)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension HomeCoordinator {
    func showChannelChatting(channelID: String) {
        let coordinator = ChannelCoordinator(navigationController: navigationController, initialScreen: .channelChatting(channelID: channelID))
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension HomeCoordinator {
    func showChannelSearch() {
        let coordinator = ChannelCoordinator(navigationController: navigationController, initialScreen: .channelSearch)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension HomeCoordinator {
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

extension HomeCoordinator {
    enum PreviousScreen {
        case workspaceInitial
        case workspaceList
    }
        
    func showWorkspaceAdd(previousScreen: PreviousScreen) {
        let coordinator: WorkspaceCoordinator
        if previousScreen == .workspaceInitial {
            coordinator = WorkspaceCoordinator(navigationController: navigationController, initialScreen: .workspaceAdd(.workspaceInitial))
        } else {
            coordinator = WorkspaceCoordinator(navigationController: navigationController, initialScreen: .workspaceAdd(.workspaceList))
        }
        
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension HomeCoordinator {
    func showWorkspaceList() {
        let coordinator = WorkspaceCoordinator(navigationController: navigationController, initialScreen: .workspaceList)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}


