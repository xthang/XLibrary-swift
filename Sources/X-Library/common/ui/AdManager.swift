//
//  Created by Thang Nguyen on 11/21/21.
//

import GoogleMobileAds
import UnityAds

public class AdManager: NSObject {
	
	private let TAG = "AdMan"
	private static let TAG = "AdMan"
	
	public static var shared = AdManager()
	
	public static let uAdInitCompleted = Notification.Name(rawValue: "uAdInitCompleted")
	
	
	public static func initiate(_ tag: String) {
		NSLog("-------  \(TAG) | \(tag)")
		
		// Setup Google Mobile Ads
		GADMobileAds.sharedInstance().start { status in
			NSLog("--  \(TAG) | GADMobileAds: start: \(status.adapterStatusesByClassName)")
		}
		GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = AppConfig.gAdTestDevices
		
		// UnityAds
		if !UnityAds.isSupported() {
			NSLog("!-  \(TAG) | UnityAds is not supported")
		} else if AppConfig.unityAdEnabled {
			UnityAds.initialize(AppConfig.unityGameID, testMode: false, initializationDelegate: AdManager.shared)
		}
	}
}

// Unity Ads
extension AdManager: UnityAdsInitializationDelegate {
	public func initializationComplete() {
		NSLog("--  \(TAG) | UAds: initializationComplete")
		
		NotificationCenter.default.post(name: AdManager.uAdInitCompleted, object: nil)
	}
	
	public func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
		NSLog("!-  \(TAG) | UAds: initializationFailed: \(error) | withMessage: \(message)")
	}
}

