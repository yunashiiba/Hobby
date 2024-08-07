//
//  AppDelegate.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/12.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
            noticeSet()
        }
        
        return true
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

    // UNUserNotificationCenterDelegate メソッド
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .list, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
        }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
            
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            completionHandler()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let noticeViewController = storyboard.instantiateViewController(withIdentifier: "NoticeViewController") as? NoticeViewController {
            noticeViewController.modalPresentationStyle = .fullScreen
            
            if let rootViewController = window.rootViewController as? UINavigationController {
                rootViewController.pushViewController(noticeViewController, animated: true)
            } else {
                window.rootViewController?.present(noticeViewController, animated: true, completion: nil)
            }
        }
        
        completionHandler()
    }
    
}
