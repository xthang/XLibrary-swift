//
//  Created by Thang Nguyen on 9/14/21.
//

import Foundation

//internal let gameQueue = DispatchQueue(label: "game_queue")
//internal var bRunning = false

public struct EOSHelper {
	private static let TAG = "EOS"
	
	//	static var platform: EOS_HPlatform!
	
	/** Call this during the AppDelegates start up phase, didFinishLaunchingWithOptions to initialize the EOS SDK
	 *  NOTE: EOSWrapper.initializeSDK and EOSWrapper.shutdownSDK must be called on the main thread */
	public static func initializeEOS() {
		// Initialize the sdk with our product name and product version number
		//		let Result = EOSWrapper.initializeSDK("Login", version:"1.0")
		//		if Result == EOS_Success {
		//			// We are allowed to tick as soon as the application is ready and has called startGameLoop once
		//			bRunning = true
		//		}
		//		NSLog("------- \(TAG) | SDK initialized with result: \(Result.string) | \(bRunning)")
	}
	
	/** Call this during the AppDelegates termination phase, applicationWillTerminate to clean up the EOS SDK and release any created platforms
	 *  NOTE: EOSWrapper.initializeSDK and EOSWrapper.shutdownSDK must be called on the main thread */
	public static func shutdownEOS() {
		//		bRunning = false
		//
		//		gameQueue.sync {
		//			// Wait for any operations in the gameQueue to complete
		//		}
		//
		//		EOSWrapper.shutdownSDK()
	}
	
	/** Create a platform with our Dev Portal settings for this application
	 *  This is the hub that provides access to all the other interfaces */
	public static func createPlatform() -> Bool {
		// Get our applications json settings, which contains the values we obtained from the Epic Developer Portal
		//		let settings = EOSSettings()
		//		platform = EOSWrapper.createPlatform(settings.data.productId,
		//											 sandboxId: settings.data.sandboxId,
		//											 deploymentId: settings.data.deploymentId,
		//											 clientId: settings.data.clientId,
		//											 clientSecret: settings.data.clientSecret,
		//											 isServer: false, flags: 0)
		//
		//		NSLog("--  \(TAG) | Platform description: \(platform?.debugDescription ?? "--")")
		//		return platform != nil
		return false
	}
	
	/** Provided as an example of how to release a platform outside of normal shutdown handling, which already does this for us! */
	public static func releasePlatform() {
		//		if platform != nil {
		//			releasePlatform(platform)
		//			platform = nil
		//		}
	}
	
	/** Any created platforms are released as part of the shutdownEOS handling
	 *  Should you need to release a platform for some other reason this is a safe way to do so and allows any active tick processing to complete */
	//	internal static func releasePlatform(_ platform: EOS_HPlatform) {
	//		gameQueue.sync {
	//			EOSWrapper.releasePlatform(platform)
	//		}
	//	}
	
	/** Call this once from your UIViewController in viewDidLoad, to ensure the EOS SDK periodically ticks and processes messages
	 *  This will maintain calling itself every 10th of a second after the initial trigger */
	public static func startGameLoop() {
		//		gameQueue.asyncAfter(deadline: .now() + 0.1, qos: .utility) {
		//			if bRunning {
		//				EOSWrapper.tick()
		//				self.startGameLoop()
		//			}
		//		}
	}
	
	/** Register our interest in changes to the login status
	 *  We can see transitions from logged out to in and vice versa in response to calls to login and logout
	 *  Also we can see if the EOS SDK service logged us out for other reasons and keep the application in sync */
	public static func registerNotications() {
		//		EOSWrapper.addNotifyLoginStatusChanged { loggedIn, prevLoggedIn in
		//			NSLog("--  \(TAG) | LoginStatusChanged: %x -> %x", prevLoggedIn, loggedIn)
		//
		//			DispatchQueue.main.async {
		//				NotificationCenter.default.post(name: .eosLoginStatusChanged, object: loggedIn)
		//			}
		//		}
	}
	
	/** Attempt an auto login with any locally persisted credentials (from a previous successful login during another session)
	 *  It is normal for this to fail with EOS_NotFound if no persisted credentials exist */
	public static func autoLogin() {
		NSLog("--  \(TAG) | AutoLogging in...")
		
		//		EOSWrapper.loginPersistentAuth { result in
		//			NSLog("--  \(TAG) | AutoLogging: \(result.string)")
		//		}
	}
}

/** EOS Result conversion to strings, for some of the more common values */
//extension EOS_EResult {
//	var string: String {
//		switch self {
//			case EOS_Success: return "EOS_Success"
//			case EOS_NoConnection: return "EOS_NoConnection"
//			case EOS_InvalidCredentials: return "EOS_InvalidCredentials"
//			case EOS_InvalidUser: return "EOS_InvalidUser"
//			case EOS_InvalidAuth: return "EOS_InvalidAuth"
//			case EOS_AccessDenied: return "EOS_AccessDenied"
//			case EOS_MissingPermissions: return "EOS_MissingPermissions"
//			case EOS_TooManyRequests: return "EOS_TooManyRequests"
//			case EOS_InvalidParameters: return "EOS_InvalidParameters"
//			case EOS_InvalidRequest: return "EOS_InvalidRequest"
//			case EOS_IncompatibleVersion: return "EOS_IncompatibleVersion"
//			case EOS_NotConfigured: return "EOS_NotConfigured"
//			case EOS_Canceled: return "EOS_Canceled"
//			case EOS_NotFound: return "EOS_NotFound"
//			default: return String(cString: EOS_EResult_ToString(self))
//		}
//	}
//}
