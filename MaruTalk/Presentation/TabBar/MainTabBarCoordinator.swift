//
//  MainTabBarCoordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: (any Coordinator)?
    let tabBarController: UITabBarController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }
    
    deinit {
        print("DEBUG: MainTabBarCoordinator deinit")
    }
    
    func start() {
        let homeVC = HomeViewController()
        let homeCoordinator = HomeCoordinator(navigationController: navigationController, viewController: homeVC)
        homeCoordinator.viewController = homeVC
        homeCoordinator.parentCoordinator = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        
        let dmVC = DMViewController()
        let dmCoordinator = DMCoordinator(navigationController: navigationController, viewController: dmVC)
        dmCoordinator.viewController = dmVC
        dmCoordinator.parentCoordinator = self
        childCoordinators.append(dmCoordinator)
        dmCoordinator.start()
        
        let searchVC = SearchViewController()
        let searchCoordinator = SearchCoordinator(navigationController: navigationController, viewController: searchVC)
        searchCoordinator.viewController = searchVC
        searchCoordinator.parentCoordinator = self
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
        
        let settingVC = SettingViewController()
        let settingCoordinator = SettingCoordinator(navigationController: navigationController, viewController: settingVC)
        settingCoordinator.viewController = settingVC
        settingCoordinator.parentCoordinator = self
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
        
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_active"))
        dmVC.tabBarItem = UITabBarItem(title: "DM", image: UIImage(named: "message"), selectedImage: UIImage(named: "message_active"))
        searchVC.tabBarItem = UITabBarItem(title: "검색", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile_active"))
        settingVC.tabBarItem = UITabBarItem(title: "설정", image: UIImage(named: "setting"), selectedImage: UIImage(named: "setting_active"))
        
        //Appearance
        let appearance = UITabBarAppearance()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = Constant.Color.brandBlack
        
        tabBarController.setViewControllers([homeVC, dmVC, searchVC, settingVC], animated: false)
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        navigationController.viewControllers = []
        if let appCoordinator = parentCoordinator as? AppCoordinator {
            appCoordinator.showOnboarding()
        }
    }
}
