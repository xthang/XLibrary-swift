//
//  AppDelegate.swift
//  Numbers
//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit
import AVFoundation
import StoreKit

//import Firebase
//import FBSDKCoreKit

open class BaseAppDelegate: UIResponder, UIApplicationDelegate {
	
	private static let TAG = "_☯️"
	private let TAG = "_☯️"
	
	public var window: UIWindow?
	
	
	open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		NSLog("\(TAG) -- didFinishLaunchingWithOptions: \(application) | \(launchOptions as Any)")
		
		NSSetUncaughtExceptionHandler { exception in
			Helper.log("uncaught-exception", exception)
		}
		
		AppConfig.initiate(TAG)
		
		Helper.getConfig(TAG, data: launchOptions == nil ? nil : ["launchOptions": "\(launchOptions!)"]) { _,_ in }
		
		//if #available(iOS 14, *) {
		//	ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
		//		Helper.track()
		//	}
		//}
		
		try? AVAudioSession.sharedInstance().setCategory(.ambient)
		
		_ = Singletons.instance
		
		// Register for remote notifications. This shows a permission dialog on first run, to
		// show the dialog at a more appropriate time move this registration accordingly.
		// [START register_for_notifications]
		//if #available(iOS 10.0, *) {
		//	// For iOS 10 display notification (sent via APNS)
		//	let notiDelegate = UserNotificationCenterDelegate()
		//	UNUserNotificationCenter.current().delegate = notiDelegate
		//
		//	let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		//	UNUserNotificationCenter.current().requestAuthorization(
		//		options: authOptions,
		//		completionHandler: { status, error in
		//			NSLog("--  \(AppDelegate.TAG) | UserNotification: requestAuthorization: \(status) | ERROR: \(error as Any? ?? "--")")
		//		})
		//} else {
		//	let settings: UIUserNotificationSettings =
		//		UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
		//	application.registerUserNotificationSettings(settings)
		//}
		
		//application.registerForRemoteNotifications()
		
		// Setup font
		//		UILabel.appearance().font = UIFont(name: AppConfig.defaultFont, size: UIFont.labelFontSize)
		//		UIButton.appearance().titleLabel?.font = UIFont(name: AppConfig.defaultFont, size: UIFont.labelFontSize)
		//		UITextView.appearance().font = UIFont(name: AppConfig.defaultFont, size: UIFont.labelFontSize)
		
		ADBanner.initiate()
		
		// Setup firebase
		//		FirebaseApp.configure()
		//		Messaging.messaging().delegate = self
		
		// Setup Facebook SDK
		//ApplicationDelegate.shared.application(
		//	application,
		//	didFinishLaunchingWithOptions: launchOptions
		//)
		//Profile.enableUpdatesOnAccessTokenChange(false)
		
		// Initialize the EOS SDK ready for use
		EOSHelper.initializeEOS()
		
		// Create platform allows us to to access the various interfaces and identify our application settings with values we obtained from the Dev Portal
		if (EOSHelper.createPlatform()) {
			// Track login status changes
			EOSHelper.registerNotications()
		} else {
			NSLog("!-  \(TAG) | EOS CreatePlatform Failed")
		}
		
		return true
	}
	
	deinit {
		NSLog("~~~~~~~  \(TAG)")
	}
	
	// MARK: UISceneSession Lifecycle
	
	// Remove this func if app does not implement Scenes
	@available(iOS 13.0, *)
	public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		NSLog("\(TAG) -- connectingSceneSession | \(connectingSceneSession.debugDescription) | \(options)")
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	@available(iOS 13.0, *)
	public func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
		NSLog("\(TAG) -- didDiscardSceneSessions")
	}
	
	// These below methods are not called if app implements Scene
	
	public func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		NSLog("\(TAG) -- applicationWillResignActive: \(application)")
	}
	
	public func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		NSLog("\(TAG) -- applicationDidEnterBackground: \(application)")
	}
	
	public func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		NSLog("\(TAG) -- applicationWillEnterForeground: \(application)")
	}
	
	public func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		NSLog("\(TAG) -- applicationDidBecomeActive: \(application)")
	}
	
	public func applicationWillTerminate(_ application: UIApplication) {
		NSLog("\(TAG) -- applicationWillTerminate: \(application)")
		
		SKPaymentQueue.default().remove(Payment.shared)
		
		EOSHelper.releasePlatform()
		// Shutdown and cleanup EOS SDK, this also releases any created platforms
		EOSHelper.shutdownEOS()
	}
	
	// MARK: Noti handling
	public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		NSLog("\(TAG) -- Unable to register for remote notifications: \(error.localizedDescription)")
		
		// XT test
		//Messaging.messaging().apnsToken = Data()
	}
	
	// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
	// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
	// the FCM registration token.
	public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		NSLog("\(TAG) -- APNs token retrieved: \(deviceToken)")
		
		Helper.sendDeviceTokenToServer(deviceToken: deviceToken)
		// With swizzling disabled you must set the APNs token here.
		//Messaging.messaging().apnsToken = deviceToken
	}
	
	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
					 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		NSLog("\(TAG) -- Remote Noti received: \(userInfo)")
		
		// Print message ID.
		if let messageID = userInfo[CommonConfig.gcmMessageIDKey] {
			NSLog("-- \(TAG) | GCM Message ID: \(messageID)")
		}
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		completionHandler(UIBackgroundFetchResult.newData)
	}
	
	public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		
		// Determine who sent the URL.
		let sendingAppID = options[.sourceApplication]
		NSLog("\(TAG) -- open from url: \(url) | source application = \(sendingAppID ?? "--")")
		
		//ApplicationDelegate.shared.application(
		//	app,
		//	open: url,
		//	sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
		//	annotation: options[UIApplication.OpenURLOptionsKey.annotation]
		//)
		
		// Process the URL.
		// example: myphotoapp:Vacation?index=1
		guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
			  let path = components.path,
			  let params = components.queryItems else {
				  NSLog("--  \(TAG) | Invalid URL or album path missing")
				  return false
			  }
		
		if let index = params.first(where: { $0.name == "index" })?.value {
			NSLog("--  \(TAG) | path = \(path) | index = \(index)")
			return true
		} else {
			NSLog("--  \(TAG) | index missing")
			return false
		}
	}
	
	// this method is replaced by above application(_:open:options:)
	public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		NSLog("\(TAG) -- open from url 1: \(url) | sourceApplication: \(sourceApplication ?? "--") | annotation: \(annotation)")
		
		return false
	}
}

@available(iOS 10.0, *)
class UserNotificationCenterDelegate : NSObject, UNUserNotificationCenterDelegate {
	private static let TAG = "NotiDel"
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		NSLog("\(UserNotificationCenterDelegate.TAG) -- Noti: \(notification) | userInfo: \(userInfo)")
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		// Change this to your preferred presentation option
		if #available(iOS 14.0, *) {
			completionHandler([[.badge, .sound, .alert, .list, .banner]])
		} else {
			completionHandler([[.badge, .sound, .alert]])
		}
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		NSLog("\(UserNotificationCenterDelegate.TAG) -- Noti resp: \(response) | userInfo: \(userInfo)")
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		completionHandler()
	}
}

//extension AppDelegate : MessagingDelegate {
//	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//		NSLog("\(TAG) -- Firebase registration token: didReceiveRegistrationToken: \(messaging) | \(fcmToken ?? "")")
//
//		//		let dataDict:[String: String] = ["token": fcmToken ?? ""]
//		//		NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//		// TODO: If necessary send token to application server.
//		// Note: This callback is fired at each app startup and whenever a new token is generated.
//
//		Helper.sendFCMTokenToServer(fcmToken: fcmToken)
//	}
//}
