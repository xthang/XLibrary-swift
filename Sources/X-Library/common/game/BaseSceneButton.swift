//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit
import SpriteKit

open class BaseSceneButton: XButton, IButton {
	
	private let TAG = "_SceneBtn"
	
	public var buttonIdentifier: ButtonIdentifier!
	
	var responder: ButtonResponder? {
		var view: UIView = self
		while (view.superview != nil && !(view is SKView)) {
			view = view.superview!
		}
		guard let view = view as? SKView else { return nil }
		guard let scene = view.scene as? ButtonResponder else {
			fatalError("\(TAG) | SceneButton may only be used within a `ButtonResponder` scene.")
		}
		return scene
	}
	
	var rootView: OverlayView {
		var view: UIView = self
		while (view.superview != nil && !(view is OverlayView)) {
			view = view.superview!
		}
		return view as! OverlayView
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		buttonIdentifier = ButtonIdentifier(rawValue: accessibilityIdentifier!)
		if buttonIdentifier == nil {
			fatalError("\(TAG) | Unsupported button name found: \(accessibilityIdentifier!)")
		}
		
		enterForeground(nil)
		
		switch buttonIdentifier {
			case .DEV:
#if !DEBUG
				isHidden = true
#endif
				break
			case .sound, .ads:
				if #available(iOS 13.0, *) {
					NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
				} else {
					NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
				}
				
				if buttonIdentifier == .ads {
					NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: .AdsStatusChanged, object: nil)
				}
			default: break
		}
	}
	
	@objc func enterForeground(_ notification: NSNotification?) {
		switch buttonIdentifier! {
			case .sound:
				let isOn = Helper.soundOn
				let title = NSLocalizedString("SOUND: \(isOn ? "ON" : "OFF")", comment: "")
				setTitle(title, for: .normal)
			case .ads:
				let title: String
				if !(notification?.object as? Bool ?? true) || Helper.adsRemoved {
					title = NSLocalizedString("ADS REMOVED", comment: "")
					isEnabled = false
				} else {
					title = NSLocalizedString("REMOVE ADS", comment: "")
					isEnabled = true
				}
				setTitle(title, for: .normal)
				setTitle(title, for: .disabled)
			default:
				break
		}
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if buttonIdentifier != .sound { super.touchesEnded(touches, with: event) }
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		if !bounds.contains(location) { return }
		
		switch buttonIdentifier! {
			case .DEV:
				Helper.showDevView(TAG)
			case .close, .home, .play, .cancel, .pause, .resume, .replay:
				let responder = self.responder
				
				rootView.dismissView(self) { [unowned self] in
					responder?.buttonTriggered(self)
				}
			case .about:
				let aboutView = UINib(nibName: "About", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
				rootView.addSubview(aboutView)
			case .hint, .share:
				responder?.buttonTriggered(self)
			case .sound:
				let isOn = !Helper.soundOn
				let title = NSLocalizedString("SOUND: \(isOn ? "ON" : "OFF")", comment: "")
				setTitle(title, for: .normal)
				UserDefaults.standard.set(isOn, forKey: CommonConfig.Settings.sound)
				NotificationCenter.default.post(name: .sound, object: isSelected)
			case .rate:
				Helper.showAppRatingDialog(TAG)
			case .gameCenter:
				GameCenterHelper.showGameCenter(TAG)
			case .leaderboards:
				GameCenterHelper.showGameCenterLeaderBoard(TAG)
			case .achievements:
				GameCenterHelper.showGameCenterAchievement(TAG)
			case .ads:
				Helper.showAdsRemovalDialog(TAG)
			case .back, .settings:
				fatalError("\(TAG) | Unsupported SceneButton with id '\(buttonIdentifier.rawValue)'")
		}
		
		if buttonIdentifier == .sound { super.touchesEnded(touches, with: event) }
	}
}
