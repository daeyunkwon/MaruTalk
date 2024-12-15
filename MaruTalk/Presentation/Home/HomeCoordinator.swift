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
    enum PreviousScreen {
        case workspaceInitial
        case workspaceList
    }
    
    func showWorkspaceAdd(previousScreen: PreviousScreen) {
        var reactor: WorkspaceAddReactor
        if previousScreen == .workspaceInitial {
            reactor = WorkspaceAddReactor(previousScreen: .workspaceInitial)
        } else {
            reactor = WorkspaceAddReactor(previousScreen: .workspaceList)
        }
        
        let workspaceAddVC = WorkspaceAddViewController(reactor: reactor)
        workspaceAddVC.coordinator = self

        let navController = UINavigationController(rootViewController: workspaceAddVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(navController, animated: true)
    }
    
    func didFinishWorkspaceAdd() {
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
    func showWorkspaceList() {
        let reactor = WorkspaceListReactor()
        let workspaceListVC = WorkspaceListViewController(reactor: reactor)
        workspaceListVC.coordinator = self
        workspaceListVC.modalPresentationStyle = .overFullScreen
        navigationController.present(workspaceListVC, animated: false)
    }
    
    func didFinishWorkspaceList() {
        navigationController.dismiss(animated: false)
    }
}

extension HomeCoordinator {
    func showWorkspaceEdit(viewController: UIViewController, workspace: Workspace) {
        let reactor = WorkspaceEditReactor(workspace: workspace)
        let workspaceEditVC = WorkspaceEditViewController(reactor: reactor)
        workspaceEditVC.coordinator = self
        
        let navController = UINavigationController(rootViewController: workspaceEditVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        viewController.present(navController, animated: true)
    }
    
    func didFinishWorkspaceEdit() {
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.dismiss(animated: true)
        }
    }
}

extension HomeCoordinator {
    func showWorkspaceChangeAdmin(viewController: UIViewController) {
        let reactor = WorkspaceChangeAdminReactor()
        let workspaceEditVC = WorkspaceChangeAdminViewController(reactor: reactor)
        workspaceEditVC.coordinator = self
        
        let navController = UINavigationController(rootViewController: workspaceEditVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        viewController.present(navController, animated: true)
    }
    
    func didFinishWorkspaceChangeAdmin() {
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.dismiss(animated: true)
        }
    }
}
