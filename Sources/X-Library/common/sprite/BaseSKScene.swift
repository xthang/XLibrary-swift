//
//  Created by Thang Nguyen on 10/15/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

open class BaseSKScene: SKScene {
	
	private let TAG = "BSKS"
	
	public var entities = [GKEntity]()
	public var graphs = [String : GKGraph]()
	
	internal var soundOn: Bool = Helper.soundOn
	internal var musicOn: Bool = Helper.musicOn
	internal var vibrationOn: Bool = Helper.vibrationOn
	
	public var backgroundSoundPlayer : AVAudioPlayer?
	public var sounds: [SKAudioNode] = []
	
	private let disableTouchNode = SKSpriteNode(color: SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1), size: .zero)
	
	public var overlays: [OverlayView] = []
	
	
	open override func sceneDidLoad() {
		NSLog("--  \(TAG) | sceneDidLoad: \(hash) | \(frame)")
		
		NotificationCenter.default.addObserver(self, selector: #selector(toggleMusic), name: .music, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeMusicVolume), name: .musicVolume, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(toggleSound), name: .sound, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeSoundVolume), name: .soundVolume, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(toggleVibration), name: .vibration, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
	}
	
	deinit {
		
	}
	
	open override func willMove(from view: SKView) {
		NSLog("--  \(TAG) | willMove from view")
		super.willMove(from: view)
		
		// view.subviews.forEach { $0.removeFromSuperview() } // not working: it removes the next Overlay
		overlays.forEach { $0.removeFromSuperview() }
	}
	
	open override func didChangeSize(_ oldSize: CGSize) {
		// NSLog("--  \(TAG) | didChangeSize: \(view?.frame as Any? ?? "--") | \(frame)")
		
		disableTouchNode.size = self.size
	}
	
	open func activate(_ tag: String, _ notification: NSNotification) {
		NSLog("--  \(TAG) | activate [\(tag)]: \(hash)")
	}
	
	open func deactivate(_ tag: String, _ notification: NSNotification) {
		NSLog("--  \(TAG) | deactivate [\(tag)]: \(hash)")
		
		pause("deactivate|\(tag)")
	}
	
	open func pause(_ tag: String) {
		NSLog("--  \(TAG) | pause [\(tag)]: \(hash)")
	}
	
	open func resume(_ tag: String) {
		NSLog("--  \(TAG) | resume [\(tag)]: \(hash)")
	}
	
	public func setUserInteraction(_ enabled: Bool) {
		isUserInteractionEnabled = enabled
		
		if enabled {
			disableTouchNode.removeFromParent()
		} else if disableTouchNode.parent == nil {
			disableTouchNode.isUserInteractionEnabled = true
			disableTouchNode.zPosition = SceneLayer.disableAllLayer.rawValue
			self.addChild(disableTouchNode)
		}
	}
	
	public func show(_ overlay: Popup) {
		addChild(overlay)
		overlay.alpha = 0
		overlay.run(SKAction.fadeIn(withDuration: 0.25))
		overlay.updateScale()
	}
	
	public func show(_ overlay: OverlayView) {
		overlays.append(overlay)
		view!.addSubview(overlay)
		setUserInteraction(false)
	}
	
	public func playSound(_ audio: SKAudioNode) {
		if soundOn {
			if !audioEngine.isRunning {
				NSLog("--  \(TAG) | playSound: audioEngine.isRunning: not")
				do {
					try audioEngine.start()
				} catch {
					NSLog("--  \(TAG) | playSound: start Engine: error: \(error)")
				}
			}
			audio.run(SKAction.play())
		}
	}
	
	public func vibrate(_ feedbackGenerator : UIFeedbackGenerator?) {
		if vibrationOn, #available(iOS 10.0, *) {
			if let hapticGen = (feedbackGenerator as? UINotificationFeedbackGenerator) {
				hapticGen.notificationOccurred(.success)
			} else if let hapticGen = (feedbackGenerator as? UIImpactFeedbackGenerator) {
				hapticGen.impactOccurred()
			}
		}
	}
	
	@objc public func toggleSound(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleSound: \(notification.object ?? "--")")
		soundOn = notification.object as! Bool
	}
	
	@objc public func changeSoundVolume(_ notification: NSNotification) {
		let vol = notification.object as! Float
		sounds.forEach { $0.run(SKAction.changeVolume(to: vol, duration: 0)) }
	}
	
	@objc public func toggleMusic(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleMusic: \(notification.object ?? "--")")
		musicOn = notification.object as! Bool
	}
	
	@objc public func changeMusicVolume(_ notification: NSNotification) {
		let vol = notification.object as! Float
		backgroundSoundPlayer?.volume = vol
	}
	
	@objc public func toggleVibration(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleVibration: \(notification.object ?? "--")")
		vibrationOn = notification.object as! Bool
	}
	
	//	private func takeScreenshot(_ shouldSave: Bool = false) -> UIImage? {
	//		let layer = UIApplication.shared.keyWindow!.layer
	//		let scale = UIScreen.main.scale
	//
	//		UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
	//		guard let context = UIGraphicsGetCurrentContext() else {return nil}
	//		layer.render(in:context)
	//		let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
	//		UIGraphicsEndImageContext()
	//
	//		if let image = screenshotImage, shouldSave {
	//			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
	//		}
	//		return screenshotImage
	//	}
	
	//	private func getScreenshot() -> UIImage? {
	//		let snapshotView = self.view!.snapshotView(afterScreenUpdates: true)
	//		let bounds = UIScreen.main.bounds
	//
	//		UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
	//		snapshotView?.drawHierarchy(in: bounds, afterScreenUpdates: true)
	//		let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
	//		UIGraphicsEndImageContext()
	//
	//		return screenshotImage;
	//	}
	
	//	private func takeScreenshot() -> UIImage? {
	//		if let img = view!.texture(from: self)?.cgImage() {
	//			return UIImage(cgImage: img)
	//		}
	//		return nil
	//	}
	
	@objc func handleAudioSessionRouteChange(_ notification: NSNotification) {
		NSLog("--  \(TAG) | handleAudioSessionRouteChange: \(notification.object ?? "--") | \(notification.userInfo as Any? ?? "--") | audioEngine.isRunning: \(audioEngine.isRunning)")
		
		guard
			let userInfo = notification.userInfo,
			let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
			let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRaw.uintValue)
		else { fatalError("!-  \(TAG) | Strange... could not get routeChange") }
		
		NSLog("--  \(TAG) | handleAudioSessionRouteChange: reasonRaw: \(reasonRaw) | reason: \(reason)")
		
		// Switch over the route change reason.
		switch reason {
			case .newDeviceAvailable: // New device found.
				let session = AVAudioSession.sharedInstance()
				let headphonesConnected = hasHeadphones(in: session.currentRoute)
				NSLog("--  \(TAG) | handleAudioSessionRouteChange: newDeviceAvailable: headphonesConnected: \(headphonesConnected)")
			case .oldDeviceUnavailable: // Old device removed.
				if let previousRoute =
					userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
					let headphonesConnected = hasHeadphones(in: previousRoute)
					NSLog("--  \(TAG) | handleAudioSessionRouteChange: oldDeviceUnavailable: headphonesConnected: \(headphonesConnected)")
				}
			default: ()
		}
		
		// TODO: restart stopped audio engine
	}
	
	func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
		// Filter the outputs to only those with a port type of headphones.
		return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
	}
}
