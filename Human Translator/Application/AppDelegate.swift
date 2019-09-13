//  AppDelegate.swift
//  Human Translator
//
//  Created by Yin on 07/02/2018.
//  Copyright © 2018 Yin. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import SwiftyJSON
import EBBannerView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let gcmMessageIDKey = "gcm.message_id"
    
    
    var videoCallStautsDelegate: VideoCallStatusDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Enable SSL globally for WebRTC in our app
        RTCPeerConnectionFactory.initializeSSL()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        
        
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("willResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 
        print("Did Become Active")
        
        if application.applicationIconBadgeNumber > 0 {
            //TODO:- call API to get notification object
        }
        application.applicationIconBadgeNumber = 0
        
//        if (launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary) != nil {
//            self.application(application, didReceiveRemoteNotification: launchOptions![UIApplicationLaunchOptionsKey.remoteNotification]! as! [AnyHashable: Any])
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        switch application.applicationState {
            
        case .inactive:
            print("Inactive")
            //Show the view with the content of the push
            completionHandler(.newData)
            
        case .background:
            print("Background")
            //Refresh the local model
            completionHandler(.newData)
            
        case .active:
            print("Active")
            //Show an in-app banner
            //
            
            completionHandler(UIBackgroundFetchResult.newData)
        }
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
        
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
   
    func registerToken() {
        
        if currentUser?.id == 0 {
            return
        }
        
        if let token = UserDefaults.standard.string(forKey: R.String.KEY_TOKEN) {
            
            ApiRequest.saveToken(token: token, completion: { (rescode) in
                
            })
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        let body = notification.request.content.body
        let userInfo = notification.request.content.userInfo
        let json = JSON(userInfo)
        let type = json[R.String.PARAM_MSGTYPE].stringValue
        let room_no = json[R.String.PARAM_ROOMNO].stringValue
        
        let user = UserModel()
        user.id = json[R.String.PARAM_USERID].intValue
        user.photo_url = json[R.String.PARAM_PHOTOURL].stringValue
        
        let banner = EBBannerView.banner({ (make) in
            make?.style = EBBannerViewStyle(rawValue: 11)
            make?.icon = UIImage.init(named: "AppIcon")
            make?.title = R.String.APP_NAME
            make?.content = body
            make?.date = "Now"
        })
        
        
        if type == R.String.KEY_REQUEST {
            
            banner?.show()
            
            let videoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            
            videoVC.roomName = room_no
            videoVC.user = user
            videoVC.roomStatus = R.Const.IS_RECEIVING
            
            let vc = UINavigationController(rootViewController: videoVC)
            self.window?.rootViewController?.present(vc, animated: false, completion: nil)

        } else { // when sender send decline notiication
            //
            self.videoCallStautsDelegate?.statusChanged(type)
            /////////////////
            //banner?.show()
            /*
            
            let callingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingViewController") as! CallingViewController
            //This is new object not current vc
            //so you sitll have errror
            //should send action to curret vc
            
            callingVC.status = R.Const.IS_RECEIVING
            callingVC.declineCall()
                
                
            
            let videoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            videoVC.roomStatus = R.Const.IS_CALLING
            videoVC.loaded = true
            videoVC.statusVC.declineCall()
            */
            
        }
 
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}

// [END ios_10_message_handling]
// [START ios_10_data_message_handling]

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        UserDefaults.standard.set(fcmToken, forKey: R.String.KEY_TOKEN)
        registerToken()
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

protocol VideoCallStatusDelegate {
    func statusChanged(_ stauts: String)
}

