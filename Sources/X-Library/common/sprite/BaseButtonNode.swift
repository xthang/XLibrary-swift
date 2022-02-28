/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `ButtonNode` is a custom `SKSpriteNode` that provides button-like behavior in a SpriteKit scene. It is supported by `ButtonNodeResponderType` (a protocol for classes that can respond to button presses) and `ButtonIdentifier` (an enumeration that defines all of the kinds of buttons that are supported in the game).
 */

import SpriteKit

public protocol IButton {
	var buttonIdentifier: ButtonIdentifier! { get set }
}

/// A type that can respond to `ButtonNode` button press events.
public protocol ButtonResponder {
	/// Responds to a button press.
	func buttonTriggered(_ button: IButton)
}

/// The complete set of button identifiers supported in the app.
public enum ButtonIdentifier: String {
	case DEV = "DEV"
	case close = "Close"
	case cancel = "Cancel"
	case home = "Home"
	case about = "About"
	case play = "Play"
	case pause = "Pause"
	case resume = "Resume"
	case replay = "Replay"
	case back = "Back"
	case hint = "Hint"
	case settings = "Settings"
	case sound = "Sound"
	case gameCenter = "GameCenter"
	case leaderboards = "Leaderboards"
	case achievements = "Achievements"
	case rate = "Rate"
	case share = "Share"
	case ads = "Ads"
}

/// A custom sprite node that represents a press able and selectable button in a scene.
open class BaseButtonNode: SKSpriteNode, IButton {
	
	private let TAG = "_BtnNode"
	
	// MARK: Properties
	
	/// The identifier for this button, deduced from its name in the scene.
	public var buttonIdentifier: ButtonIdentifier!
	
	var soundEnabled: Bool = true
	
	/**
	 The scene that contains a `ButtonNode` must be a `ButtonNodeResponderType`
	 so that touch events can be forwarded along through `buttonPressed()`.
	 */
	var responder: ButtonResponder {
		guard let responder = scene as? ButtonResponder else {
			fatalError("\(TAG) | ButtonNode may only be used within a `ButtonNodeResponderType` scene.")
		}
		return responder
	}
	
	var overlayView: SceneOverlay? {
		var node: SKNode = self
		while (node.parent != nil && !(node is SceneOverlay)) {
			node = node.parent!
		}
		return node as? SceneOverlay
	}
	
	var isEnabled = false {
		didSet {
			isUserInteractionEnabled = isEnabled
			
			imgNode?.alpha = isEnabled ? 1 : 0.7
			labelNode?.colorBlendFactor = isEnabled ? 0.7 : 0.0
		}
	}
	
	/// Indicates whether the button is currently highlighted (pressed).
	var isHighlighted = false {
		// Animate to a pressed / unpressed state when the highlight state changes.
		didSet {
			// Guard against repeating the same action.
			guard oldValue != isHighlighted else { return }
			
			// Remove any existing animations that may be in progress.
			removeAllActions()
			
			// Create a scale action to make the button look like it is slightly depressed.
			let newScale: CGFloat = isHighlighted ? 0.93 : 1
			let scaleAction = SKAction.scale(to: newScale, duration: 0.15)
			
			// Create a color blend action to darken the button slightly when it is depressed.
			let newColorBlendFactor: CGFloat = isHighlighted ? 1.0 : 0.0
			let colorBlendAction = SKAction.colorize(withColorBlendFactor: newColorBlendFactor, duration: 0.15)
			
			// Run the two actions at the same time.
			run(SKAction.group([scaleAction, colorBlendAction]))
			labelNode?.colorBlendFactor = isHighlighted ? 0.7 : 0.0
		}
	}
	
	/**
	 Indicates whether the button is currently selected (on or off).
	 Most buttons do not support or require selection. In DemoBots,
	 selection is used by the screen recorder buttons to indicate whether
	 screen recording is turned on or off.
	 */
	var isSelected = false {
		didSet {
			// Change the texture based on the current selection state.
			texture = isSelected ? selectedTexture : defaultTexture
		}
	}
	
	/// The texture to use when the button is not selected.
	var defaultTexture: SKTexture?
	
	/// The texture to use when the button is selected.
	var selectedTexture: SKTexture?
	
	/// A mapping of neighboring `ButtonNode`s keyed by the `ControlInputDirection` to reach the node.
	var focusableNeighbors = [ControlInputDirection: BaseButtonNode]()
	
	/**
	 Input focus shows which button will be triggered when the action
	 button is pressed on indirect input devices such as game controllers
	 and keyboards.
	 */
	public var isFocused = false {
		didSet {
			if isFocused {
				run(SKAction.scale(to: 1.08, duration: 0.20))
				
				focusRing?.alpha = 0.0
				focusRing?.isHidden = false
				focusRing?.run(SKAction.fadeIn(withDuration: 0.2))
			} else {
				run(SKAction.scale(to: 1.0, duration: 0.20))
				
				focusRing?.run(SKAction.sequence([
					SKAction.fadeOut(withDuration: 0.5),
					SKAction.hide()
				]))
			}
		}
	}
	
	public lazy var imgNode = self.childNode(withName: "img") as? SKSpriteNode
	
	public lazy var labelNode = self.childNode(withName: "labelNode") as? SKLabelNode
	
	/// A node to indicate when a button has the input focus.
	public lazy var focusRing = self.childNode(withName: "focusRing") as? SKSpriteNode
	
	// MARK: Initializers
	
	/// Overridden to support `copy(with zone:)`.
	override init(texture: SKTexture?, color: SKColor, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// Ensure that the node has a supported button identifier as its name.
		guard let nodeName = name else {
			fatalError("\(TAG) | Button name is null")
		}
		guard let buttonIdentifier = ButtonIdentifier(rawValue: nodeName) else {
			fatalError("\(TAG) | Unsupported button name found: \(nodeName)")
		}
		self.buttonIdentifier = buttonIdentifier
		
		initiate("1")
		update(nil)
	}
	
	public init(id: ButtonIdentifier, texture: SKTexture) {
		super.init(texture: nil, color: .clear, size: .zero)
		
		self.buttonIdentifier = id
		self.name = id.rawValue
		
		let imgNode = SKSpriteNode(texture: texture)
		imgNode.name = "img"
		addChild(imgNode)
		
		initiate("2")
		update(nil)
	}
	
	func initiate(_ tag: String) {
		// Remember the button's default texture (taken from its texture in the scene).
		defaultTexture = texture
		
		// Otherwise, use the default `texture`.
		selectedTexture = texture
		
		imgNode?.texture?.filteringMode = .nearest
		
		// The focus ring should be hidden until the button is given the input focus.
		focusRing?.isHidden = true
		
		// Enable user interaction on the button node to detect tap and click events.
		isUserInteractionEnabled = true
		
		switch buttonIdentifier {
			case .DEV:
#if !DEBUG
				isHidden = true
#endif
				break
			case .sound, .ads:
				if #available(iOS 13.0, *) {
					NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIScene.willEnterForegroundNotification, object: nil)
				} else {
					NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIApplication.willEnterForegroundNotification, object: nil)
				}
				
				if buttonIdentifier == .ads {
					NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: .AdsStatusChanged, object: nil)
				}
			default: break
		}
	}
	
	open override func copy(with zone: NSZone? = nil) -> Any {
		let newButton = super.copy(with: zone) as! BaseButtonNode
		
		// Copy the `ButtonNode` specific properties.
		newButton.buttonIdentifier = buttonIdentifier
		newButton.defaultTexture = defaultTexture?.copy() as? SKTexture
		newButton.selectedTexture = selectedTexture?.copy() as? SKTexture
		
		return newButton
	}
	
	@objc func update(_ notification: NSNotification?) {
		switch buttonIdentifier! {
			case .sound:
				let isOn = Helper.soundOn
				let title = NSLocalizedString("SOUND: \(isOn ? "ON" : "OFF")", comment: "")
				labelNode?.text = title
				let t = SKTexture(imageNamed: "sound_\(isOn ? "on" : "off")")
				t.filteringMode = .nearest
				imgNode?.texture = t
			case .ads:
				let title: String
				let t: SKTexture
				if !(notification?.object as? Bool ?? true) || Helper.adsRemoved {
					title = NSLocalizedString("ADS REMOVED", comment: "")
					t = SKTexture(imageNamed: "button_ads_removed")
					isEnabled = false
				} else {
					title = NSLocalizedString("REMOVE ADS", comment: "")
					t = SKTexture(imageNamed: "button_ads")
					isEnabled = true
				}
				t.filteringMode = .nearest
				labelNode?.text = title
				imgNode?.texture = t
			default:
				break
		}
	}
	
	open func buttonTriggered() {
		if isUserInteractionEnabled {
			if Helper.soundOn && soundEnabled { Singletons.instance.btnSound?.play() }
			
			// Forward the button press event through to the responder.
			switch buttonIdentifier! {
				case .close, .home, .play, .cancel, .pause, .resume, .replay, .back:
					if let overlayView = overlayView {
						let responder = self.responder
						
						overlayView.removeFromParent("buttonTriggered") { [unowned self] in
							responder.buttonTriggered(self)
						}
					} else {
						responder.buttonTriggered(self)
					}
				case .about:
					let aboutView = UINib(nibName: "About", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
					scene!.view!.addSubview(aboutView)
				case .hint, .share:
					responder.buttonTriggered(self)
				case .sound:
					isSelected = !isSelected
					let title = NSLocalizedString("Sound: ", comment: "") + (isSelected ? "ON" : "OFF")
					labelNode?.text = title
					UserDefaults.standard.set(isSelected, forKey: CommonConfig.Settings.sound)
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
				case .DEV, .settings:
					fatalError("\(TAG) | Unsupported buttonNode with id '\(buttonIdentifier.rawValue)'")
			}
		}
	}
	
	/**
	 Performs an animation to indicate when a user is trying to navigate
	 away but no other focusable buttons are available in the requested
	 direction.
	 */
	func performInvalidFocusChangeAnimationForDirection(direction: ControlInputDirection) {
		let animationKey = "ButtonNode.InvalidFocusChangeAnimationKey"
		guard action(forKey: animationKey) == nil else { return }
		
		// Find the reference action from `ButtonFocusActions.sks`.
		let theAction: SKAction
		switch direction {
			case .up:    theAction = SKAction(named: "InvalidFocusChange_Up")!
			case .down:  theAction = SKAction(named: "InvalidFocusChange_Down")!
			case .left:  theAction = SKAction(named: "InvalidFocusChange_Left")!
			case .right: theAction = SKAction(named: "InvalidFocusChange_Right")!
		}
		
		run(theAction, withKey: animationKey)
	}
	
	// MARK: Responder
	
#if os(iOS)
	/// UIResponder touch handling.
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		isHighlighted = true
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		isHighlighted = false
		
		// Touch up inside behavior.
		if containsTouches(touches: touches) {
			buttonTriggered()
		}
	}
	
	open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
		super.touchesCancelled(touches!, with: event)
		
		isHighlighted = false
	}
	
	/// Determine if any of the touches are within the `ButtonNode`.
	private func containsTouches(touches: Set<UITouch>) -> Bool {
		guard let scene = scene else { fatalError("\(TAG) | Button must be used within a scene.") }
		
		return touches.contains { touch in
			let touchPoint = touch.location(in: scene)
			let touchedNode = scene.atPoint(touchPoint)
			return touchedNode === self || touchedNode.inParentHierarchy(self)
		}
	}
	
#elseif os(OSX)
	/// NSResponder mouse handling.
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		
		isHighlighted = true
	}
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		
		isHighlighted = false
		
		// Touch up inside behavior.
		if containsLocationForEvent(event) {
			buttonTriggered()
		}
	}
	
	/// Determine if the event location is within the `ButtonNode`.
	private func containsLocationForEvent(_ event: NSEvent) -> Bool {
		guard let scene = scene else { fatalError("Button must be used within a scene.")  }
		
		let location = event.location(in: scene)
		let clickedNode = scene.atPoint(location)
		return clickedNode === self || clickedNode.inParentHierarchy(self)
	}
#endif
}
