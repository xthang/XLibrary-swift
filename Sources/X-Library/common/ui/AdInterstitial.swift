//
//  Created by Thang Nguyen on 11/21/21.
//

import UIKit

import GoogleMobileAds
import UnityAds

public class AdInterstitial: NSObject {
	
	private let TAG = "AdInt"
	private static let TAG = "AdInt"
	
	public static var shared = AdInterstitial("shared")
	
	private var gAdInterstitial: GADInterstitialAd?
	private var uAdInterstitial: GADInterstitialAd?
	
	private let scene: UIResponder?
	
	private var uAdLoaded = false
	
	
	public init(_ tag: String, scene: UIResponder? = nil) {
		print("-------  \(TAG) | \(tag)")
		
		self.scene = scene
		super.init()
		
		loadGAd("init")
		
		// NotificationCenter.default.addObserver(self, selector: #selector(loadUAd), name: AdManager.uAdInitCompleted, object: nil)
	}
	
	public func loadGAd(_ tag: String) {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | loadGAd: ads are removed")
			return
		}
		print("--  \(TAG) | loadGAd [\(tag)]")
		
		let request = GADRequest()
		if #available(iOS 13.0, *) {
			request.scene = (scene as! UIWindowScene)
		}
		GADInterstitialAd.load(withAdUnitID: AppConfig.GADUnit.interstitial,
							   request: request,
							   completionHandler: { [self] ad, error in
			if let error = error {
				NSLog("!-  \(TAG) | Failed to load interstitial ad with error: \(error.localizedDescription)")
				loadUAd("GAD.load.error", nil)
				return
			}
			gAdInterstitial = ad
			gAdInterstitial?.fullScreenContentDelegate = self
		})
	}
	
	@objc public func loadUAd(_ tag: String, _ notification: Notification?) {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | loadUAd: ads are removed")
			return
		}
		print("--  \(TAG) | loadUAd [\(tag)]: \(notification?.object as Any? ?? "--")")
		
		UnityAds.load(AppConfig.UnityAdUnit.interstitial, loadDelegate: self)
	}
	
	public func present(_ tag: String, in viewController: UIViewController) -> Bool {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | present [\(tag)]: ads are removed")
			return false
		}
		print("--  \(TAG) | present [\(tag)]")
		
		if gAdInterstitial != nil {
			let canPresent: Bool
			do {
				try gAdInterstitial?.canPresent(fromRootViewController: viewController)
				canPresent = true
			} catch {
				NSLog("!-  \(TAG) | interstitial?.canPresent [\(tag)]: \(error.localizedDescription)")
				canPresent = false
			}
			if canPresent {
				gAdInterstitial!.present(fromRootViewController: viewController)
				return true
			}
		}
		if uAdLoaded {
			UnityAds.show(viewController, placementId: AppConfig.UnityAdUnit.interstitial, showDelegate: self)
			return true
		} else {
			NSLog("!-  \(TAG) | Ad wasn't ready [\(tag)]")
			loadGAd("present|\(tag)")
			return false
		}
	}
}

extension AdInterstitial: GADFullScreenContentDelegate {
	
	public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
		print("!-  \(TAG) | adDidRecordImpression: \(ad)")
	}
	
	public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
		NSLog("!-  \(TAG) | adDidRecordClick: \(ad)")
	}
	
	/// Tells the delegate that the ad failed to present full screen content.
	public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		NSLog("!-  \(TAG) | Ad did fail to present full screen content.: \(error)")
	}
	
	/// Tells the delegate that the ad presented full screen content.
	public func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		print("--  \(TAG) | Ad did present full screen content.")
	}
	
	/// Tells the delegate that the ad dismissed full screen content.
	public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		print("--  \(TAG) | Ad did dismiss full screen content.")
		
		loadGAd("adDismissed")
	}
}

// For Interstitial display ads & Rewarded video ads
extension AdInterstitial: UnityAdsLoadDelegate {
	
	public func unityAdsAdLoaded(_ placementId: String) {
		print("<-- \(TAG) | UAds: unityAdsAdLoaded: \(placementId)")
		
		uAdLoaded = true
	}
	
	public func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
		NSLog("!-- \(TAG) | UAds: unityAdsAdFailed: \(placementId) | error: \(error) | withMessage: \(message)")
	}
}

// For Interstitial display ads & Rewarded video ads
extension AdInterstitial: UnityAdsShowDelegate {
	
	public func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
		print("--  \(TAG) | UAds: unityAdsShowComplete: \(placementId) | withFinish: \(state)")
	}
	
	public func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
		NSLog("!-  \(TAG) | UAds: unityAdsShowFailed: \(placementId) | error: \(error) | withMessage: \(message)")
	}
	
	public func unityAdsShowStart(_ placementId: String) {
		print("--  \(TAG) | UAds: unityAdsShowStart: \(placementId)")
	}
	
	public func unityAdsShowClick(_ placementId: String) {
		NSLog("--  \(TAG) | UAds: unityAdsShowClick: \(placementId)")
	}
}
