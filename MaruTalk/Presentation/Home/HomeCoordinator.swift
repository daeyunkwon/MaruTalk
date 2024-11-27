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
    func showWorkspaceAdd() {
        let reactor = WorkspaceAddReactor(previousScreen: .workspaceInitial)
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
        let reactor = ChannelAddReactor()
        let channelAddVC = ChannelAddViewController(reactor: reactor)
        channelAddVC.coordinator = self

        let navController = UINavigationController(rootViewController: channelAddVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(navController, animated: true)
    }
    
    func didFinishChannelAdd() {
        navigationController.dismiss(animated: true)
    }
}

extension HomeCoordinator {
    func showChannelChatting(channelID: String) {
        let reactor = ChannelChattingReactor(viewType: .channel(channelID: channelID))
        let channelChattingVC = ChannelChattingViewController(reactor: reactor)
        channelChattingVC.coordinator = self
        navigationController.pushViewController(channelChattingVC, animated: true)
    }
    
    func didFinishChannelChatting() {
        navigationController.popViewController(animated: true)
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
        let reactor = ChannelSearchReactor()
        let channelChattingVC = ChannelSearchViewController(reactor: reactor)
        channelChattingVC.coordinator = self
        navigationController.pushViewController(channelChattingVC, animated: true)
    }
    
    func didFinishChannelSearch() {
        navigationController.popViewController(animated: true)
    }
}
