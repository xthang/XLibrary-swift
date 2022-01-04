//
//  Created by Thang Nguyen on 6/28/21.
//

import CoreGraphics

import GoogleMobileAds
import UnityAds

public class ADBanner: NSObject {
	
	private let TAG = "ADS"
	private static let TAG = "ADS"
	
	public static var shared = ADBanner("shared")
	private var rootViewController: UIViewController?
	
	private var banner: UIView
	private var gAdBanner: GADBannerView
	private var uADSBanner: UADSBannerView?
	
	private var position: BannerPosition = .bottom
	
	private var uAdLoaded = false
	
	
	public init(_ tag: String) {
		print("-------  \(TAG) | \(tag)")
		
		banner = UIView()
		// banner.layer.zPosition = 990
		gAdBanner = GADBannerView()
		super.init()
		
		gAdBanner.adUnitID = AppConfig.GADUnit.banner
		gAdBanner.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.adsStatusChanged), name: .AdsStatusChanged, object: nil)
	}
	
	public func show(_ tag: String, viewController: UIViewController, position: BannerPosition? = nil) {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | show in viewController [\(tag)]: ads are removed")
			return
		}
		
		rootViewController = viewController
		gAdBanner.rootViewController = viewController
		
		if gAdBanner.responseInfo?.responseIdentifier != nil {
			show("show|\(tag)|1", adBanner: gAdBanner, position: position ?? self.position)
		} else if uAdLoaded {
			show("show|\(tag)|2", adBanner: uADSBanner!, position: position ?? self.position)
		} else {
			reloadAd("show|\(tag)")
		}
		if position != nil {
			self.position = position!
		}
	}
	
	public func reloadAd(_ tag: String) {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | reloadAd [\(tag)]: ads are removed")
			return
		}
		guard let viewController = rootViewController, let view = viewController.view
		else {
			NSLog("!-  \(TAG) | reloadAd [\(tag)]: viewController/view is nil")
			return
		}
		
		// Step 2 - Determine the view width to use for the ad width.
		// commented because safeAreaInsets change in portrait/landscape mode
		let frame = { () -> CGRect in
			// Here safe area is taken into account, hence the view frame is used
			// after the view has been laid out.
			//	if #available(iOS 11.0, *) {
			//		return view.frame.inset(by: view.safeAreaInsets)
			//	} else {
			return view.frame
			//	}
		}()
		let viewWidth = min(frame.size.width, frame.size.height)
		let newAdWidth = floor(viewWidth * (UIDevice.current.userInterfaceIdiom == .phone ? 0.95 : 0.85))
		if gAdBanner.adSize.size.width == newAdWidth && gAdBanner.responseInfo != nil {
			NSLog("!-  \(TAG) | reloadAd [\(tag)]: adSize.size.width == viewWidth == \(newAdWidth) && responseInfo != nil")
			return
		}
		
		print("--  \(TAG) | reloading Ad [\(tag)]: \(viewController) | \(viewWidth) | \(gAdBanner.adSize.size.width) -> \(newAdWidth)")
		
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
	
	func reloadUAd(_ tag: String) {
		if Helper.adsRemoved {
			NSLog("!-  \(TAG) | reloadUAd [\(tag)]: ads are removed")
			return
		}
		
		let size = gAdBanner.adSize.size
		let newAdSize = CGSize(width: max(320, size.width), height: max(50, size.height))
		if uAdLoaded && uADSBanner!.size == newAdSize {
			NSLog("!-  \(TAG) | reload UAd [\(tag)]: uAdLoaded && uADSBanner.size == newAdSize == \(newAdSize)")
			return
		}
		
		print("--  \(TAG) | reloading UAd [\(tag)]: \(rootViewController as Any? ?? "--") | \(uADSBanner?.size as Any? ?? "--") -> \(newAdSize)")
		
		uADSBanner = UADSBannerView(placementId: AppConfig.UnityAdUnit.banner, size: newAdSize)
		uADSBanner!.delegate = self
		
		uADSBanner!.load()
		uAdLoaded = false
	}
	
	private func show(_ tag: String, adBanner: UIView, position: BannerPosition) {
		if banner.superview != nil && banner.superview == rootViewController?.view
				&& position == self.position {
			print("!-  \(TAG) | [\(tag)] already shown in: \(rootViewController?.view as Any? ?? rootViewController as Any? ?? "--") | \(position)")
			return
		}
		print("!-  \(TAG) | show [\(tag)]: \(rootViewController?.view as Any? ?? rootViewController as Any? ?? "--") | \(position)")
		
		banner.removeFromSuperview()
		adBanner.removeFromSuperview()
		banner.subviews.forEach({ $0.removeFromSuperview() })
		
		guard let viewController = rootViewController, let view = viewController.view
		else {
			NSLog("!-  \(TAG) | [\(tag)] show in: \(rootViewController?.view as Any? ?? rootViewController as Any? ?? "--")")
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
	
	public func remove(_ tag: String) {
		NSLog("--  \(TAG) | remove [\(tag)]")
		
		banner.removeFromSuperview()
		rootViewController = nil
	}
	
	@objc func adsStatusChanged(_ notification: NSNotification) {
		NSLog("--  \(TAG) | adsStatusChanged: \(notification.object ?? "--")")
		
		if notification.object as! Bool {
			
		} else {
			remove("adsStatusChanged")
		}
	}
}

public enum BannerPosition: CaseIterable {
	case top, bottom
}

extension ADBanner: GADBannerViewDelegate {
	public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		print("<-- \(TAG) | GAds: bannerViewDidReceiveAd: \(rootViewController as Any? ?? "--") | \(bannerView.responseInfo?.adNetworkClassName as Any? ?? "--")")
		
		show("bannerViewDidReceiveAd", adBanner: bannerView, position: position)
	}
	
	public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
		NSLog("<-- \(TAG) | GAds: bannerView: didFailToReceiveAdWithError: \(error.localizedDescription)")
		
		reloadUAd("didFailToReceiveAdWithError")
	}
	
	public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
		print("--  \(TAG) | GAds: bannerViewDidRecordImpression")
	}
	
	public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
		print("--  \(TAG) | GAds: bannerViewWillPresentScreen")
	}
	
	public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
		print("--  \(TAG) | GAds: bannerViewWillDIsmissScreen")
	}
	
	public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
		print("--  \(TAG) | GAds: bannerViewDidDismissScreen")
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

// For Banner ads
extension ADBanner: UADSBannerViewDelegate {
	public func bannerViewDidLoad(_ bannerView: UADSBannerView) {
		print("<-- \(TAG) | UAds: bannerViewDidLoad: \(bannerView.placementId)")
		
		uAdLoaded = true
		show("bannerViewDidLoad", adBanner: bannerView, position: position)
	}
	
	public func bannerViewDidClick(_ bannerView: UADSBannerView) {
		NSLog("--  \(TAG) | UAds: bannerViewDidClick: \(bannerView.placementId)")
	}
	
	public func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView) {
		print("--  \(TAG) | UAds: bannerViewDidLeaveApplication: \(bannerView.placementId)")
	}
	
	public func bannerViewDidError(_ bannerView: UADSBannerView, error: UADSBannerError) {
		NSLog("!-  \(TAG) | UAds: bannerViewDidError: \(bannerView.placementId) | error: \(error)")
	}
}
