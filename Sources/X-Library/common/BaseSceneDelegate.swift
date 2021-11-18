//
//  Created by Thang Nguyen on 6/23/21.
//

import UIKit

import FBSDKCoreKit

@available(iOS 13.0, *)
open class BaseSceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	private static let TAG = "_🔵"
	private let TAG = "_🔵"
	
	public var window: UIWindow?
	public var adBanner = ADBanner()
	
	
	open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		NSLog("\(TAG) -- scene: \(scene.hash) | \(session.hash) | \(connectionOptions)")
		guard let _ = (scene as? UIWindowScene) else { return }
		
		// Determine who sent the URL.
		if let urlContext = connectionOptions.urlContexts.first {
			let sendingAppID = urlContext.options.sourceApplication
			let url = urlContext.url
			NSLog("--  \(TAG) | scene: source application = \(sendingAppID ?? "--") | url = \(url)")
			
			// Process the URL similarly to the UIApplicationDelegate example.
			// example: myphotoapp:Vacation?index=1
		}
	}
	
	public func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
		NSLog("\(TAG) -- sceneDidDisconnect: \(scene.hash)")
	}
	
	public func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
		NSLog("\(TAG) -- sceneDidBecomeActive: \(scene.hash)")
	}
	
	public func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
		NSLog("\(TAG) -- sceneWillResignActive: \(scene.hash)")
	}
	
	public func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
		NSLog("\(TAG) -- sceneWillEnterForeground: \(scene.hash)")
	}
	
	public func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
		NSLog("\(TAG) -- sceneDidEnterBackground: \(scene.hash)")
	}
	
	//
	public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		NSLog("\(TAG) -- openURLContexts: \(URLContexts)")
		
		// Determine who sent the URL.
		if let urlContext = URLContexts.first {
			let sendingAppID = urlContext.options.sourceApplication
			let url = urlContext.url
			NSLog("--  \(TAG) | openURLContexts: source application = \(sendingAppID ?? "--") | url = \(url)")
			
			// Process the URL similarly to the UIApplicationDelegate example.
			// example: myphotoapp:Vacation?index=1
			
			//ApplicationDelegate.shared.application(
			//	UIApplication.shared,
			//	open: url,
			//	sourceApplication: nil,
			//	annotation: [UIApplication.OpenURLOptionsKey.annotation]
			//)
		}
	}
}
