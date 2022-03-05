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
	
	private let disableTouchNode = SKSpriteNode()
	private let dimLayer = SKSpriteNode(color: SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2), size: .zero)
	
	public var overlays: [OverlayView] = []
	
	
	open override func sceneDidLoad() {
		NSLog("--  \(TAG)|\(type(of: self)) | sceneDidLoad: \(hash) | \(frame)")
		
		NotificationCenter.default.addObserver(self, selector: #selector(toggleMusic), name: .music, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeMusicVolume), name: .musicVolume, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(toggleSound), name: .sound, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeSoundVolume), name: .soundVolume, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(toggleVibration), name: .vibration, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
		
		disableTouchNode.zPosition = SceneLayer.disableSceneLayer.rawValue
		disableTouchNode.isUserInteractionEnabled = true
		dimLayer.zPosition = SceneLayer.disableSceneLayer.rawValue
	}
	
	deinit {
		
	}
	
	open override func didChangeSize(_ oldSize: CGSize) {
		NSLog("--  \(TAG)|\(type(of: self)) | didChangeSize: \(oldSize) -> \(size) | \(view?.frame as Any? ?? "--") | \(frame) | \(scaleMode.rawValue)")
		
		disableTouchNode.size = self.size
		dimLayer.size = self.size
	}
	
	open override func willMove(from view: SKView) {
		NSLog("--  \(TAG)|\(type(of: self)) | willMove from view")
		super.willMove(from: view)
		
		// view.subviews.forEach { $0.removeFromSuperview() } // not working: it removes the next Overlay
		overlays.forEach { $0.removeFromSuperview() }
	}
	
	open func deactivate(_ tag: String, _ notification: NSNotification) {
		NSLog("--  \(TAG)|\(type(of: self)) | deactivate [\(tag)]: \(hash)")
		
		pause("deactivate|\(tag)")
	}
	
	open func activate(_ tag: String, _ notification: NSNotification) {
		NSLog("--  \(TAG)|\(type(of: self)) | activate [\(tag)]: \(hash)")
	}
	
	open func pause(_ tag: String) {
		NSLog("--  \(TAG)|\(type(of: self)) | pause [\(tag)]: \(hash)")
	}
	
	open func resume(_ tag: String) {
		NSLog("--  \(TAG)|\(type(of: self)) | resume [\(tag)]: \(hash)")
	}
	
	public func setUserInteraction(_ tag: String, _ enabled: Bool, _ lightDimmed: Bool = false) {
		isUserInteractionEnabled = enabled
		
		if enabled {
			disableTouchNode.removeFromParent()
			dimLayer.removeFromParent()
		} else if disableTouchNode.parent == nil {
			self.addChild(disableTouchNode)
		}
	}
	
	public func dim(_ tag: String, _ on: Bool) {
		if !on {
			dimLayer.removeFromParent()
		} else if dimLayer.parent == nil {
			self.addChild(dimLayer)
		}
	}
	
	public func show(_ overlay: SceneOverlay) {
		setUserInteraction("showOverlay", false)
		dim("showOverlay", true)
		
		if overlay.parent != nil {
			print("--  \(TAG)|\(type(of: self)) | show overlay: already show")
			return
		}
		
		overlay.willMove("\(TAG)|\(type(of: self))|show", to: self)
		addChild(overlay)
		overlay.didMove("\(TAG)|\(type(of: self))|show", to: self)
	}
	
	public func show(_ overlay: OverlayView) {
		setUserInteraction("showOverlay", false)
		// dim("showOverlay", true) // ???
		overlays.append(overlay)
		view!.addSubview(overlay)
	}
	
	public func playSound(_ audio: SKAudioNode, delay: TimeInterval? = nil) {
		if soundOn {
			if !audioEngine.isRunning {
				NSLog("--  \(TAG)|\(type(of: self)) | playSound: audioEngine.isRunning: not")
				do {
					try audioEngine.start()
				} catch {
					NSLog("--  \(TAG)|\(type(of: self)) | playSound: start Engine: error: \(error)")
				}
			}
			if delay != nil {
				audio.run(.sequence([
					.wait(forDuration: delay!),
					.play()
				]), withKey: "play")
			} else {
				audio.run(.play(), withKey: "play")
			}
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
		NSLog("--  \(TAG)|\(type(of: self)) | toggleSound: \(notification.object ?? "--")")
		soundOn = notification.object as! Bool
	}
	
	@objc public func changeSoundVolume(_ notification: NSNotification) {
		let vol = notification.object as! Float
		sounds.forEach { $0.run(.changeVolume(to: vol, duration: 0)) }
	}
	
	@objc public func toggleMusic(_ notification: NSNotification) {
		NSLog("--  \(TAG)|\(type(of: self)) | toggleMusic: \(notification.object ?? "--")")
		musicOn = notification.object as! Bool
	}
	
	@objc public func changeMusicVolume(_ notification: NSNotification) {
		let vol = notification.object as! Float
		backgroundSoundPlayer?.volume = vol
	}
	
	@objc public func toggleVibration(_ notification: NSNotification) {
		NSLog("--  \(TAG)|\(type(of: self)) | toggleVibration: \(notification.object ?? "--")")
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
		NSLog("--  \(TAG)|\(type(of: self)) | handleAudioSessionRouteChange: \(notification.object ?? "--") | \(notification.userInfo as Any? ?? "--") | audioEngine.isRunning: \(audioEngine.isRunning)")
		
		guard
			let userInfo = notification.userInfo,
			let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
			let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRaw.uintValue)
		else { fatalError("!-  \(TAG) | Strange... could not get routeChange") }
		
		NSLog("--  \(TAG)|\(type(of: self)) | handleAudioSessionRouteChange: reasonRaw: \(reasonRaw) | reason: \(reason)")
		
		// Switch over the route change reason.
		switch reason {
			case .newDeviceAvailable: // New device found.
				let session = AVAudioSession.sharedInstance()
				let headphonesConnected = hasHeadphones(in: session.currentRoute)
				NSLog("--  \(TAG)|\(type(of: self)) | handleAudioSessionRouteChange: newDeviceAvailable: headphonesConnected: \(headphonesConnected)")
			case .oldDeviceUnavailable: // Old device removed.
				if let previousRoute =
						userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
					let headphonesConnected = hasHeadphones(in: previousRoute)
					NSLog("--  \(TAG)|\(type(of: self)) | handleAudioSessionRouteChange: oldDeviceUnavailable: headphonesConnected: \(headphonesConnected)")
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
