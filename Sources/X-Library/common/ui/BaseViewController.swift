//
//  GameViewController.swift
//  Shoot
//
//  Created by Thang Nguyen on 03/04/22.
//

import UIKit

open class BaseViewController: UIViewController {
	
	private static let TAG = "~VC"
	private let TAG = "~VC"
	
	private var isFirstLoad = true
	public var canShowWelcome: Bool!
	public var newUpdateIsNotified = false
	
	@IBOutlet public weak var devBtn: UIButton!
	
	// @IBOutlet weak var masterView: UIView!
	// @IBOutlet weak var statusBar: StatusBar!
	
	public var welcomeView: BaseWelcomeView?
	
	private var adBanner: ADBanner!
	public var adInterstitial: AdInterstitial!
	
	public var lastShowAdInterstitial = Date()
	
	
	open override func viewDidLoad() {
		NSLog("--  \(TAG) | viewDidLoad: \(hash) | \(view.frame.size)")
		super.viewDidLoad()
		
		//
		NotificationCenter.default.addObserver(self, selector: #selector(self.adsStatusChanged(_:)), name: .AdsStatusChanged, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.homeEntered), name: .homeEntered, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.gameEntered), name: .gameEntered, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.gameFinished), name: .gameFinished, object: nil)
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		NSLog("--  \(TAG) | viewDidAppear: \(hash) - animated: \(animated) | \(isFirstLoad)")
		super.viewDidAppear(animated)
		
		if isFirstLoad {
			isFirstLoad = false
			
			if #available(iOS 13.0, *) {
				NotificationCenter.default.removeObserver(self, name: UIScene.willDeactivateNotification, object: view.window!.windowScene!)
				NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: view.window!.windowScene!)
				NotificationCenter.default.addObserver(self, selector: #selector(self.deactivate), name: UIScene.willDeactivateNotification, object: view.window!.windowScene!)
				NotificationCenter.default.addObserver(self, selector: #selector(self.activate), name: UIScene.didActivateNotification, object: view.window!.windowScene!)
			} else {
				NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
				NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
				NotificationCenter.default.addObserver(self, selector: #selector(self.deactivate), name: UIApplication.willResignActiveNotification, object: nil)
				NotificationCenter.default.addObserver(self, selector: #selector(self.activate), name: UIApplication.didBecomeActiveNotification, object: nil)
			}
			
			// Note loadBannerAd is called in viewDidAppear as this is the first time that
			// the safe area is known. If safe area is not a concern (e.g., your app is
			// locked in portrait mode), the banner can be loaded in viewWillAppear.
			
			/*
			 The case of multi-window introduces a requirement of having a window scene for sending ad requests.
			 Since a view has not yet been added to a window in viewDidLoad:, you should instead build ad requests in viewDidAppear: where the window scene is set by that point.
			 */
			if #available(iOS 13.0, *) {
				self.adBanner = (view.window!.windowScene!.delegate as? BaseSceneDelegate)?.adBanner ?? ADBanner.shared
				self.adInterstitial = (view.window!.windowScene!.delegate as? BaseSceneDelegate)?.adInterstitial ?? AdInterstitial.shared
			} else {
				self.adBanner = ADBanner.shared
				self.adInterstitial = AdInterstitial.shared
			}
			
			// set scene after viewDidAppear so skView size is defined
			// if storedAppVersion is never set & canShowWelcome -> show welcome
			// else if storedAppVersion is never set & not canShowWelcome -> show home, not show app-updated noti
			// else if storedAppVersion is set & storedAppVersion != current appVersion -> show home, show app-updated noti
			// after all, set storedAppVersion
			if canShowWelcome && UserDefaults.standard.object(forKey: CommonConfig.Keys.newAppUpdateNotiVersion) == nil {
				showWelcome()
			} else {
				loadHomeView("viewDidAppear")
				
				// uncomment this if loadHomeView is called in viewDidLoad, because HomeScene can not post Notification.homeEntered
				// checkAndUpdateAdsBanner("viewDidAppear", !Helper.adsRemoved)
			}
		}
	}
	
	private func showWelcome() {
		welcomeView!.onCompletion { [unowned self] in
			loadHomeView("showWelcome")
		}
		view.addSubview(welcomeView!)
	}
	
	open func loadHomeView(_ tag: String) {
		// show Noti on new version update
		let appVersion = Helper.appVersion
		let newAppUpdateNotiVersion = UserDefaults.standard.object(forKey: CommonConfig.Keys.newAppUpdateNotiVersion) as? String
		if newAppUpdateNotiVersion != appVersion {
			if newAppUpdateNotiVersion != nil {
				newUpdateIsNotified = true
				
				let alert = PopupAlert.initiate(title: NSLocalizedString("YOUR APP HAS BEEN UPDATED", comment: ""), message: "\(NSLocalizedString("NEW VERSION", comment: "")): \(appVersion)")
				alert.dismissOutside = false
				
				_ = alert.addAction(title: NSLocalizedString("LET'S PLAY", comment: ""), style: .primary1) { [unowned self] in
					newUpdateIsNotified = false
					
					UserDefaults.standard.set(appVersion, forKey: CommonConfig.Keys.newAppUpdateNotiVersion)
					
					GameCenterHelper.authenticateLocalPlayer(TAG, self)
					
					onNewUpdateNotified()
				}
				view.addSubview(alert)
			} else {
				UserDefaults.standard.set(appVersion, forKey: CommonConfig.Keys.newAppUpdateNotiVersion)
			}
		}
		
		if !newUpdateIsNotified {
			GameCenterHelper.authenticateLocalPlayer(TAG, self)
		}
	}
	
	open func onNewUpdateNotified() {}
	
	open override func viewWillTransition(to size: CGSize,
													  with coordinator: UIViewControllerTransitionCoordinator) {
		NSLog("--  \(TAG) | viewWillTransition: to size: \(size)")
		super.viewWillTransition(to:size, with:coordinator)
		
		coordinator.animate(alongsideTransition: { [unowned self] _ in
			self.adBanner?.reloadAd("\(TAG)|viewWillTransition")
		})
	}
	
	open override func didReceiveMemoryWarning() {
		NSLog("!-  \(TAG) | didReceiveMemoryWarning")
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}
	
	@objc open func deactivate(_ noti: NSNotification) {}
	
	@objc open func activate(_ noti: NSNotification) {}
	
	public func updateAdsBanner(_ tag: String, _ on: Bool, position: BannerPosition? = nil) {
		if adBanner == nil {
			print("--  \(TAG) | updateAdsBanner [\(tag)]: adBanner is null")
			return
		}
		
		if on {
			adBanner?.show("\(TAG)|updateAdsBanner|\(tag)", viewController: self, position: position) // allCases.randomElement()
		} else {
			adBanner?.remove("\(TAG)|updateAdsBanner|\(tag)")
		}
	}
	
	public var canShowAds = true	// in case scene is GameScene (no ad show) and adsStatusChanged noti turns ad on
	
	// check some conditions before update Ads
	open func checkAndUpdateAdsBanner(_ tag: String, _ on: Bool, position: BannerPosition? = nil) {
		NSLog("--  \(TAG) | checkAndUpdateAdsBanner [\(tag)]: on: \(on) | \(canShowAds) | \(position as Any? ?? "--")")
		
		if on && canShowAds {
			updateAdsBanner("checkAndUpdateAdsBanner|\(tag)", on, position: position)
			return
		}
		updateAdsBanner("checkAndUpdateAdsBanner|\(tag)", false)
	}
	
	@objc private func adsStatusChanged(_ notification: NSNotification) {
		checkAndUpdateAdsBanner("notification", notification.object as! Bool)
	}
	
	@objc open func homeEntered(_ notification: NSNotification) {
		NSLog("--  \(TAG) | homeEntered: \(hash) - \(notification.object ?? "--")")
		
		canShowAds = true
	}
	
	@objc open func gameEntered(_ notification: NSNotification) {
		NSLog("--  \(TAG) | gameLevelEntered: \(hash) - \(notification.object ?? "--")")
	}
	
	@objc open func gameFinished(_ notification: NSNotification) {
		NSLog("--  \(TAG) | gameLevelFinished: \(hash) - \(notification.object ?? "--")")
		
		canShowAds = true
	}
	
	open func showAdInterstitial(_ tag: String, gameNo: Int) -> Bool {
		return false
	}
}
