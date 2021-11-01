//
//  Created by Thang Nguyen on 6/28/21.
//

import GoogleMobileAds
import UnityAds
import CoreGraphics

public class ADBanner: NSObject {
	private let TAG = "ADS"
	private static let TAG = "ADS"
	
	public static var shared = ADBanner()
	var rootViewController: UIViewController?
	
	private var banner: UIView
	private var gAdBanner: GADBannerView
	private var uADSBanner: UADSBannerView?
	
	var position: BannerPosition?
	
	var uAdLoaded = false
	
	public static func initiate() {
		// Setup Google Mobile Ads
		GADMobileAds.sharedInstance().start { status in
			NSLog("--  \(ADBanner.TAG) | GADMobileAds: start: \(status.adapterStatusesByClassName)")
		}
		GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = AppConfig.gAdTestDevices
		
		// UnityAds
		if !UnityAds.isSupported() {
			NSLog("!-  \(ADBanner.TAG) | UnityAds is not supported")
		} else if AppConfig.unityAdEnabled {
			UnityAds.initialize(AppConfig.unityGameID, testMode: false, enablePerPlacementLoad: true, initializationDelegate: ADBanner.shared)
		}
	}
	
	public override init() {
		banner = UIView()
		// banner.layer.zPosition = 990
		gAdBanner = GADBannerView()
		super.init()
		
		gAdBanner.adUnitID = AppConfig.GADUnit.main
		gAdBanner.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.purchased), name: .inAppPurchased, object: nil)
	}
	
	public func show(viewController: UIViewController, position: BannerPosition? = nil) {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | show in viewController: ads are removed")
			return
		}
		
		rootViewController = viewController
		gAdBanner.rootViewController = viewController
		self.position = position
		
		if gAdBanner.responseInfo?.responseIdentifier != nil {
			show(adBanner: gAdBanner)
		} else if uAdLoaded {
			show(adBanner: uADSBanner!)
		} else {
			reloadAd()
		}
	}
	
	public func reloadAd() {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | reloadAd: ads are removed")
			return
		}
		guard let viewController = rootViewController, let view = viewController.view
		else {
			NSLog("!-  \(TAG) | reloadAd: viewController/view is nil")
			return
		}
		
		// Step 2 - Determine the view width to use for the ad width.
		let frame = { () -> CGRect in
			// Here safe area is taken into account, hence the view frame is used
			// after the view has been laid out.
			if #available(iOS 11.0, *) {
				return view.frame.inset(by: view.safeAreaInsets)
			} else {
				return view.frame
			}
		}()
		let viewWidth = min(frame.size.width, frame.size.height)
		let newAdWidth = floor(viewWidth * (UIDevice.current.userInterfaceIdiom == .phone ? 0.95 : 0.85))
		if gAdBanner.adSize.size.width == newAdWidth && gAdBanner.responseInfo != nil {
			NSLog("!-  \(TAG) | reloadAd: adSize.size.width == viewWidth == \(newAdWidth) && responseInfo != nil")
			return
		}
		
		NSLog("--  \(TAG) | reloading Ad: \(viewController) | \(viewWidth) | \(gAdBanner.adSize.size.width) -> \(newAdWidth)")
		
		// Step 3 - Get Adaptive GADAdSize and set the ad view.
		// Here the current interface orientation is used. If the ad is being preloaded
		// for a future orientation change or different orientation, the function for the
		// relevant orientation should be used.
		gAdBanner.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(newAdWidth)
		
		// Step 4 - Create an ad request and load the adaptive banner ad.
		let request = GADRequest()
		if #available(iOS 13.0, *) {
			// The case of multi-window introduces a requirement of having a window scene for sending ad requests.
			request.scene = view.window?.windowScene
		}
		gAdBanner.load(request)
	}
	
	func reloadUAd() {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | reloadUAd: ads are removed")
			return
		}
		
		let size = gAdBanner.adSize.size
		let newAdSize = CGSize(width: max(320, size.width), height: max(50, size.height))
		if uAdLoaded && uADSBanner!.size == newAdSize {
			NSLog("!-  \(TAG) | reload UAd: uAdLoaded && uADSBanner.size == newAdSize == \(newAdSize)")
			return
		}
		
		NSLog("--  \(TAG) | reloading UAd: \(rootViewController as Any? ?? "--") | \(uADSBanner?.size as Any? ?? "--") -> \(newAdSize)")
		
		uADSBanner = UADSBannerView(placementId: AppConfig.UnityAdUnit.main, size: newAdSize)
		uADSBanner!.delegate = self
		
		uADSBanner!.load()
		uAdLoaded = false
	}
	
	private func show(adBanner: UIView) {
		banner.removeFromSuperview()
		adBanner.removeFromSuperview()
		banner.subviews.forEach({ $0.removeFromSuperview() })
		
		guard let viewController = rootViewController, let view = viewController.view
		else {
			NSLog("!-  \(TAG) | show in: \(rootViewController?.view as Any? ?? rootViewController as Any? ?? "--")")
			return
		}
		
		banner.translatesAutoresizingMaskIntoConstraints = false
		adBanner.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(banner)
		banner.addSubview(adBanner)
		
		var layoutGuide: Any
		if #available(iOS 11.0, *) {
			layoutGuide = view.safeAreaLayoutGuide
		} else {
			layoutGuide = position == .top ? viewController.topLayoutGuide : viewController.bottomLayoutGuide
		}
		let attribute: NSLayoutConstraint.Attribute = position == .top ? .top : .bottom
		
		banner.addConstraints(
			[NSLayoutConstraint(item: adBanner,
								attribute: attribute,
								relatedBy: .equal,
								toItem: banner,
								attribute: attribute,
								multiplier: 1,
								constant: 0),
			 NSLayoutConstraint(item: adBanner,
								attribute: .centerX,
								relatedBy: .equal,
								toItem: banner,
								attribute: .centerX,
								multiplier: 1,
								constant: 0)
			])
		
		view.addConstraints(
			[NSLayoutConstraint(item: banner,
								attribute: attribute,
								relatedBy: .equal,
								toItem: layoutGuide,
								attribute: attribute,
								multiplier: 1,
								constant: 0),
			 NSLayoutConstraint(item: banner,
								attribute: .centerX,
								relatedBy: .equal,
								toItem: view,
								attribute: .centerX,
								multiplier: 1,
								constant: 0)
			])
		
		banner.alpha = 0
		
		UIView.animate(withDuration: 1, animations: { [weak banner] in
			banner?.alpha = 1
		})
	}
	
	public func remove() {
		banner.removeFromSuperview()
		rootViewController = nil
	}
	
	@objc func purchased(_ notification: NSNotification) {
		if notification.object as? String == AdsStore.shared.adsRemovalID {
			NSLog("--  \(TAG) | purchased: \(hash) - \(notification.object ?? "--")")
			
			remove()
		}
	}
}

public enum BannerPosition: CaseIterable {
	case top, bottom
}

extension ADBanner: GADBannerViewDelegate {
	public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		NSLog("<-- \(TAG) | GAds: bannerViewDidReceiveAd: \(rootViewController as Any? ?? "--") | \(bannerView.responseInfo?.adNetworkClassName as Any? ?? "--")")
		
		show(adBanner: bannerView)
	}
	
	public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
		NSLog("<-- \(TAG) | GAds: bannerView: didFailToReceiveAdWithError: \(error.localizedDescription)")
		
		reloadUAd()
	}
	
	public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewDidRecordImpression")
	}
	
	public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewWillPresentScreen")
	}
	
	public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewWillDIsmissScreen")
	}
	
	public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewDidDismissScreen")
	}
}

//class xGADAdLoaderDelegate: NSObject, GADAdLoaderDelegate {
//	static let instance = xGADAdLoaderDelegate()
//
//	public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
//		NSLog("<-- \(TAG) | adLoader didReceive: \(nativeAd)")
//
//	}
//
//	func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
//		NSLog("<-- \(TAG) | adLoader didFailToReceiveAdWithError: \(error)")
//	}
//}

// Unity Ads
extension ADBanner: UnityAdsInitializationDelegate {
	public func initializationComplete() {
		NSLog("--  \(TAG) | UAds: initializationComplete")
	}
	
	public func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
		NSLog("!-  \(TAG) | UAds: initializationFailed: \(error) | withMessage: \(message)")
	}
}

// For Interstitial display ads & Rewarded video ads
extension ADBanner: UnityAdsLoadDelegate {
	public func unityAdsAdLoaded(_ placementId: String) {
		NSLog("<-- \(TAG) | UAds: unityAdsAdLoaded: \(placementId)")
	}
	
	public func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
		NSLog("!-- \(TAG) | UAds: unityAdsAdFailed: \(placementId) | error: \(error) | withMessage: \(message)")
	}
}

// For Interstitial display ads & Rewarded video ads
extension ADBanner: UnityAdsShowDelegate {
	public func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
		NSLog("--  \(TAG) | UAds: unityAdsShowComplete: \(placementId) | withFinish: \(state)")
	}
	
	public func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
		NSLog("!-  \(TAG) | UAds: unityAdsShowFailed: \(placementId) | error: \(error) | withMessage: \(message)")
	}
	
	public func unityAdsShowStart(_ placementId: String) {
		NSLog("--  \(TAG) | UAds: unityAdsShowStart: \(placementId)")
	}
	
	public func unityAdsShowClick(_ placementId: String) {
		NSLog("--  \(TAG) | UAds: unityAdsShowClick: \(placementId)")
	}
}

// For Banner ads
extension ADBanner: UADSBannerViewDelegate {
	public func bannerViewDidLoad(_ bannerView: UADSBannerView) {
		NSLog("<-- \(TAG) | UAds: bannerViewDidLoad: \(bannerView.placementId)")
		
		uAdLoaded = true
		show(adBanner: bannerView)
	}
	
	public func bannerViewDidClick(_ bannerView: UADSBannerView) {
		NSLog("--  \(TAG) | UAds: bannerViewDidClick: \(bannerView.placementId)")
	}
	
	public func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView) {
		NSLog("--  \(TAG) | UAds: bannerViewDidLeaveApplication: \(bannerView.placementId)")
	}
	
	public func bannerViewDidError(_ bannerView: UADSBannerView, error: UADSBannerError) {
		NSLog("!-  \(TAG) | UAds: bannerViewDidError: \(bannerView.placementId) | error: \(error)")
	}
}
