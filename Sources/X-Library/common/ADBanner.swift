//
//  Created by Thang Nguyen on 6/28/21.
//

import GoogleMobileAds
import UnityAds
import CoreGraphics

class ADBanner: NSObject {
	private let TAG = "ADS"
	private static let TAG = "ADS"
	
	static var shared = ADBanner()
	var rootViewController: UIViewController?
	
	private var banner: UIView
	private var gAdBanner: GADBannerView
	private var uADSBanner: UADSBannerView?
	
	var position: BannerPosition?
	
	var uAdLoaded = false
	
	static func initiate() {
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
	
	override init() {
		banner = UIView()
		gAdBanner = GADBannerView()
		super.init()
		
		gAdBanner.adUnitID = AppConfig.GADUnit.main
		gAdBanner.delegate = self
	}
	
	func show(viewController: UIViewController, position: BannerPosition? = nil) {
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
	
	func reloadAd() {
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
		let viewWidth = frame.size.width
		if gAdBanner.adSize.size.width == viewWidth && gAdBanner.responseInfo != nil {
			NSLog("!-  \(TAG) | reloadAd: adSize.size.width == viewWidth && responseInfo != nil")
			return
		}
		
		NSLog("--  \(TAG) | reloading Ad: \(viewController) | \(viewWidth)")
		
		// Step 3 - Get Adaptive GADAdSize and set the ad view.
		// Here the current interface orientation is used. If the ad is being preloaded
		// for a future orientation change or different orientation, the function for the
		// relevant orientation should be used.
		gAdBanner.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth * (UIDevice.current.userInterfaceIdiom == .phone ? 0.95 : 0.85))
		
		// Step 4 - Create an ad request and load the adaptive banner ad.
		let request = GADRequest()
		if #available(iOS 13.0, *) {
			// The case of multi-window introduces a requirement of having a window scene for sending ad requests.
			request.scene = view.window?.windowScene
		}
		gAdBanner.load(request)
	}
	
	func reloadUAd() {
		let size = gAdBanner.adSize.size
		uADSBanner = UADSBannerView(placementId: AppConfig.UnityAdUnit.main, size: CGSize(width: max(320, size.width), height: max(50, size.height)))
		uADSBanner!.delegate = self
		
		uADSBanner!.load()
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
	
	func remove() {
		banner.removeFromSuperview()
		rootViewController = nil
	}
}

enum BannerPosition: CaseIterable {
	case top, bottom
}

extension ADBanner: GADBannerViewDelegate {
	func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		NSLog("<-- \(TAG) | GAds: bannerViewDidReceiveAd: \(rootViewController as Any? ?? "--") | \(bannerView.responseInfo?.adNetworkClassName as Any? ?? "--")")
		
		show(adBanner: bannerView)
	}
	
	func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
		NSLog("<-- \(TAG) | GAds: bannerView: didFailToReceiveAdWithError: \(error.localizedDescription)")
		
		reloadUAd()
	}
	
	func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewDidRecordImpression")
	}
	
	func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewWillPresentScreen")
	}
	
	func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
		NSLog("--  \(TAG) | GAds: bannerViewWillDIsmissScreen")
	}
	
	func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
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
	func initializationComplete() {
		NSLog("--  \(TAG) | UAds: initializationComplete")
	}
	
	func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
		NSLog("!-  \(TAG) | UAds: initializationFailed: \(error) | withMessage: \(message)")
	}
}

// For Interstitial display ads & Rewarded video ads
extension ADBanner: UnityAdsLoadDelegate {
	func unityAdsAdLoaded(_ placementId: String) {
		NSLog("<-- \(TAG) | UAds: unityAdsAdLoaded: \(placementId)")
	}
	
	func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
		NSLog("!-- \(TAG) | UAds: unityAdsAdFailed: \(placementId) | error: \(error) | withMessage: \(message)")
	}
}

// For Interstitial display ads & Rewarded video ads
extension ADBanner: UnityAdsShowDelegate {
	func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
		NSLog("--  \(TAG) | UAds: unityAdsShowComplete: \(placementId) | withFinish: \(state)")
	}
	
	func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
		NSLog("!-  \(TAG) | UAds: unityAdsShowFailed: \(placementId) | error: \(error) | withMessage: \(message)")
	}
	
	func unityAdsShowStart(_ placementId: String) {
		NSLog("--  \(TAG) | UAds: unityAdsShowStart: \(placementId)")
	}
	
	func unityAdsShowClick(_ placementId: String) {
		NSLog("--  \(TAG) | UAds: unityAdsShowClick: \(placementId)")
	}
}

// For Banner ads
extension ADBanner: UADSBannerViewDelegate {
	func bannerViewDidLoad(_ bannerView: UADSBannerView) {
		NSLog("<-- \(TAG) | UAds: bannerViewDidLoad: \(bannerView.placementId)")
		
		uAdLoaded = true
		show(adBanner: bannerView)
	}
	
	func bannerViewDidClick(_ bannerView: UADSBannerView) {
		NSLog("--  \(TAG) | UAds: bannerViewDidClick: \(bannerView.placementId)")
	}
	
	func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView) {
		NSLog("--  \(TAG) | UAds: bannerViewDidLeaveApplication: \(bannerView.placementId)")
	}
	
	func bannerViewDidError(_ bannerView: UADSBannerView, error: UADSBannerError) {
		NSLog("!-  \(TAG) | UAds: bannerViewDidError: \(bannerView.placementId) | error: \(error)")
	}
}
