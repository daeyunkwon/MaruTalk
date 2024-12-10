//
//  AppDelegate.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

import FirebaseCore
import FirebaseMessaging
import RealmSwift
import RxKakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(2)
        
        appearance()
        
        RxKakaoSDK.initSDK(appKey: "f83129f04ee8161fd09fa9e28cd7f264")
        
        print("RealmSwift 경로-----------------------------")
        print(String(describing: Realm.Configuration.defaultConfiguration.fileURL))
        print("-------------------------------------------")
        
        FirebaseApp.configure()
        
        //원격 알림 등록
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        //메시지 대리자 설정(등록 토큰 수신을 위해 필요)
        Messaging.messaging().delegate = self
        
        
        
        return true
    }
    
    private func appearance() {
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

//MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.userInfo)
        return completionHandler([.badge, .banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        print(userInfo)
    }
}

//MARK: - MessagingDelegate(FCM)

extension AppDelegate: MessagingDelegate {
    
    //현재 등록 토큰(디바이스마다 고유한 토큰 정보가 있음) 가져오기
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            print("FCM registration token: \(fcmToken)")
            FCMManager.shared.saveFCMToken(token: fcmToken)
        }
    }
}

