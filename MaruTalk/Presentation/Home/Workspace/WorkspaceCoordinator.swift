//
//  WorkspaceCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/16/24.
//

import UIKit

final class WorkspaceCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    
    enum InitialScreen {
        case workspaceAdd(PreviousScreen)
        case workspaceList
    }
    
    var initialScreen: InitialScreen
    
    init(navigationController: UINavigationController, initialScreen: InitialScreen) {
        self.navigationController = navigationController
        self.initialScreen = initialScreen
    }
    
    deinit {
        print("DEBUG: \(String(describing: self)) deinit")
    }
    
    func start() {
        switch initialScreen {
        case .workspaceAdd(let previousScreen):
            showWorkspaceAdd(previousScreen: previousScreen)
        case .workspaceList:
            showWorkspaceList()
        }
    }
    
    func didFinish() {
        self.parentCoordinator?.removeCoordinator(child: self)
    }
}

extension WorkspaceCoordinator {
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
        if let onboardingCoordinator = parentCoordinator as? OnboardingCoordinator {
            onboardingCoordinator.didFinish()
        }
        
        navigationController.dismiss(animated: true)
    }
}

extension WorkspaceCoordinator {
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

extension WorkspaceCoordinator {
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

extension WorkspaceCoordinator {
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
