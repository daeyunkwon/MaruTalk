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
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController())
        let dmCoordinator = DMCoordinator(navigationController: UINavigationController())
        let searchCoordinator = SearchCoordinator(navigationController: UINavigationController())
        let settingCoordinator = SettingCoordinator(navigationController: UINavigationController())
        
        [homeCoordinator, dmCoordinator, searchCoordinator, settingCoordinator].forEach {
            if let object = $0 as? Coordinator {
                self.childCoordinators.append(object)
                object.parentCoordinator = self
                object.start()
            }
        }
        
        homeCoordinator.navigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_active"))
        dmCoordinator.navigationController.tabBarItem = UITabBarItem(title: "DM", image: UIImage(named: "message"), selectedImage: UIImage(named: "message_active"))
        searchCoordinator.navigationController.tabBarItem = UITabBarItem(title: "검색", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile_active"))
        settingCoordinator.navigationController.tabBarItem = UITabBarItem(title: "설정", image: UIImage(named: "setting"), selectedImage: UIImage(named: "setting_active"))
        
        homeCoordinator.navigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_active"))
        
        //Appearance
        let appearance = UITabBarAppearance()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = Constant.Color.brandBlack
        
        tabBarController.viewControllers = [homeCoordinator.navigationController, dmCoordinator.navigationController, searchCoordinator.navigationController, settingCoordinator.navigationController]
        
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = scene.window {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        }
    }
    
    func didFinish() {
        parentCoordinator?.removeCoordinator(child: self)
        tabBarController.viewControllers = []
        
        if let appCoordinator = parentCoordinator as? AppCoordinator {
            appCoordinator.showOnboarding()
        }
    }
}
