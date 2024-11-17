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
        let homeNavigationController = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNavigationController)
        homeCoordinator.parentCoordinator = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        
        let dmNavigationController = UINavigationController()
        let dmCoordinator = DMCoordinator(navigationController: dmNavigationController)
        dmCoordinator.parentCoordinator = self
        childCoordinators.append(dmCoordinator)
        dmCoordinator.start()
        
        let searchNavigationController = UINavigationController()
        let searchCoordinator = SearchCoordinator(navigationController: searchNavigationController)
        searchCoordinator.parentCoordinator = self
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
        
        let settingNavigationController = UINavigationController()
        let settingCoordinator = SettingCoordinator(navigationController: settingNavigationController)
        settingCoordinator.parentCoordinator = self
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
        
        homeNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_active"))
        dmNavigationController.tabBarItem = UITabBarItem(title: "DM", image: UIImage(named: "message"), selectedImage: UIImage(named: "message_active"))
        searchNavigationController.tabBarItem = UITabBarItem(title: "검색", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile_active"))
        settingNavigationController.tabBarItem = UITabBarItem(title: "설정", image: UIImage(named: "setting"), selectedImage: UIImage(named: "setting_active"))
        
        //Appearance
        let appearance = UITabBarAppearance()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = Constant.Color.brandBlack
        
        tabBarController.setViewControllers([homeNavigationController, dmNavigationController, searchNavigationController, settingNavigationController], animated: false)
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        navigationController.viewControllers = []
        if let appCoordinator = parentCoordinator as? AppCoordinator {
            appCoordinator.showOnboarding()
        }
    }
}
