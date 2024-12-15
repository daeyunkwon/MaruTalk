//
//  ChannelCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/15/24.
//

import UIKit

final class ChannelCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    
    enum InitialScreen {
        case channelAdd
        case channelSearch
        case channelChatting(channelID: String)
    }
    private var initialScreen: InitialScreen
    
    init(navigationController: UINavigationController, initialScreen: InitialScreen) {
        self.navigationController = navigationController
        self.initialScreen = initialScreen
    }
    
    deinit {
        print("DEBUG: \(String(describing: self)) deinit")
    }
    
    func start() {
        switch self.initialScreen {
        case .channelAdd:
            showChannelAdd()
        case .channelSearch:
            showChannelSearch()
        case .channelChatting(let channelID):
            showChannelChatting(channelID: channelID)
        }
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
    }
}

extension ChannelCoordinator {
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

extension ChannelCoordinator {
    func showChannelChatting(channelID: String) {
        let reactor = ChannelChattingReactor(channelID: channelID)
        let channelChattingVC = ChannelChattingViewController(reactor: reactor)
        channelChattingVC.coordinator = self
        navigationController.pushViewController(channelChattingVC, animated: true)
    }
    
    func didFinishChannelChatting() {
        navigationController.popViewController(animated: true)
    }
}

extension ChannelCoordinator {
    func showChannelSearch() {
        let reactor = ChannelSearchReactor()
        let channelSearchVC = ChannelSearchViewController(reactor: reactor)
        channelSearchVC.coordinator = self
        navigationController.pushViewController(channelSearchVC, animated: true)
    }
    
    func didFinishChannelSearch(isNavigateToChannelChatting: Bool = false) {
        if isNavigateToChannelChatting {
            //채널 채팅 화면으로 가는 경우
            ///네비게이션 스택에서 ChannelSearchVC의 인스턴스 제거
            var viewControllers = navigationController.viewControllers
            viewControllers.removeAll(where: { $0 is ChannelSearchViewController })
            navigationController.setViewControllers(viewControllers, animated: false)
        } else {
            //홈 화면으로 가는 경우
            navigationController.popViewController(animated: true)
            self.didFinish()
        }
    }
}

extension ChannelCoordinator {
    func showChannelSetting(channelID: String) {
        let reactor = ChannelSettingReactor(channelID: channelID)
        let channelSettingVC = ChannelSettingViewController(reactor: reactor)
        channelSettingVC.coordinator = self
        navigationController.pushViewController(channelSettingVC, animated: true)
    }
    
    func didFinishChannelSetting(isNaviageToHome: Bool = false) {
        if isNaviageToHome {
            if let homeVC = navigationController.viewControllers.first(where: { $0 is HomeViewController }) as? HomeViewController {
                navigationController.popToViewController(homeVC, animated: true)
            }
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}

extension ChannelCoordinator {
    func showChannelEdit(channel: Channel) {
        let reactor = ChannelEditReactor(channel: channel)
        let channelEditVC = ChannelEditViewController(reactor: reactor)
        channelEditVC.coordinator = self

        let navController = UINavigationController(rootViewController: channelEditVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(navController, animated: true)
    }
    
    func didFinishChannelEdit() {
        navigationController.dismiss(animated: true)
    }
}

extension ChannelCoordinator {
    func showChannelChangeAdmin(channelID: String) {
        let reactor = ChannelChangeAdminReactor(channelID: channelID)
        let channelChangeAdminVC = ChannelChangeAdminViewController(reactor: reactor)
        channelChangeAdminVC.coordinator = self

        let navController = UINavigationController(rootViewController: channelChangeAdminVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(navController, animated: true)
    }
    
    func didFinishChannelChangeAdmin() {
        navigationController.dismiss(animated: true)
    }
}


