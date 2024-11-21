//
//  AppDelegate.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

import RxKakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(2)
        
        appearance()
        
        RxKakaoSDK.initSDK(appKey: "f83129f04ee8161fd09fa9e28cd7f264")
        
        return true
    }
    
    func appearance() {
        UINavigationBar.appearance().tintColor = Constant.Color.brandBlack
        let appearance = UINavigationBarAppearance()
        //배경색
        appearance.configureWithOpaqueBackground() // 불투명한 배경 설정
        appearance.backgroundColor = Constant.Color.backgroundSecondary
        //타이틀
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: Constant.Color.brandBlack
        ]
        //적용
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().isTranslucent = false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

