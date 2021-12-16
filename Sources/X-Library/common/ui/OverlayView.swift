//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

open class OverlayView: UIView {
	
	private let TAG = "OV"
	
	@objc public enum AnimationStyle: Int {
		case fade
		case scale
	}
	
	@IBOutlet public var contentView: PopupWindow?
	
	@IBInspectable public var animationStyle: AnimationStyle = .fade
	
	@IBInspectable public var dismissOutside: Bool = true
	@IBInspectable public var dismissSoundEnabled: Bool = false
	
	var dismissHandler: ((_ isButton: Bool) -> Void)?
	
	
	open class func initiate(fileName: String) -> OverlayView {
		return UINib(nibName: fileName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! OverlayView
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.zPosition = 999
	}
	
	open override func willMove(toSuperview newSuperview: UIView?) {
		if newSuperview == nil { return }
		
		if animationStyle == .scale {
			contentView!.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
		} else {
			alpha = 0
		}
	}
	
	open override func didMoveToSuperview() {
		guard let view = superview else { return }
		
		// must set Constraint here, not in willMove()
		// exception 'NSGenericException', reason: 'Unable to activate constraint with anchors <NSLayoutDimension:0x2804c1e00 "X_Numbers.SceneOverlay:0x105f0b110.height"> and <NSLayoutDimension:0x2804c1ec0 "SKView:0x106822000.height"> because they have no common ancestor.  Does the constraint or its anchors reference items in different view hierarchies?  That's illegal.'
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalTo: view.heightAnchor),
			widthAnchor.constraint(equalTo: view.widthAnchor),
			topAnchor.constraint(equalTo: view.topAnchor),
			bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		
		if animationStyle == .fade {
			UIView.animate(withDuration: 0.3,
								delay: 0,
								options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
								animations: ({ [weak self] in
				self?.alpha = 1
				self?.transform = CGAffineTransform.identity
			})) { [weak self] _ in
				self?.popupDidShow("1")
			}
		} else {
			UIView.animate(withDuration: 0.3,
								delay: 0,
								usingSpringWithDamping: 0.6,
								initialSpringVelocity: 0.5,
								options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
								animations: ({ [weak self] in
				// self?.alpha = 1
				self?.contentView!.transform = CGAffineTransform.identity
			})) { [weak self] _ in
				self?.popupDidShow("2")
			}
		}
		
		//if #available(iOS 13.0, *) {
		//	NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIScene.willDeactivateNotification, object: window!.windowScene!)
		//} else {
		//	NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIApplication.willResignActiveNotification, object: nil)
		//}
	}
	
	open func popupDidShow(_ tag: String) {}
	
	//open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
	//	NSLog("~~  \(TAG) | traitCollectionDidChange")
	//}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		// if touch.view != popupWindow {	// not work if view contain subview(s)
		if dismissOutside && contentView != nil && !contentView!.frame.contains(location) {
			dismissView(nil)
		}
	}
	
	//open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
	//	// stop passing touches from an overlay view to the views underneath
	//	return true
	//}
	
	public func onDismiss(handler: @escaping (_ isButton: Bool) -> Void) {
		self.dismissHandler = handler
	}
	
	@IBAction public func dismissView(_ sender: UIControl?) {
		dismissView(sender, completion: nil)
	}
	
	@objc public func dismissView(_ sender: UIControl?, completion: (() -> Void)? = nil) {
		if dismissSoundEnabled && Helper.soundOn
				&& (sender == nil || (sender as? IXButton)?.soundEnabled != true) {
			Singletons.instance.whooshSound?.play()
		}
		
		if animationStyle == .fade {
			UIView.animate(withDuration: 0.25,
								delay: 0,
								options: [.curveEaseOut, .layoutSubviews, .allowAnimatedContent],
								animations: ({ [weak self] in
				self?.alpha = 0
			})) { [weak self] ok in
				self?.removeFromSuperview()
				self?.dismissHandler?(sender != nil)
				completion?()
			}
		} else {
			UIView.animate(withDuration: 0.15,
								delay: 0,
								options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
								animations: ({ [weak self] in
				self?.alpha = 0
				self?.contentView!.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
			})) { [weak self] _ in
				self?.removeFromSuperview()
				self?.dismissHandler?(sender != nil)
				completion?()
			}
		}
	}
	
	@objc public func test(_ noti: NSNotification) {
		NSLog("--  \(TAG) | test: \(type(of: self)) | \(self.hash)")
	}
}
