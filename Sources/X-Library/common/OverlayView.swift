//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

open class OverlayView: UIView {
	
	private let TAG = "OV"
	
	@IBOutlet public var contentView: UIView!
	
	
	open class func initiate(_ fileName: String) -> OverlayView {
		return UINib(nibName: fileName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! OverlayView
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.zPosition = 999
	}
	
	open override func willMove(toSuperview newSuperview: UIView?) {
		guard let _ = newSuperview else { return }
		
		alpha = 0
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
		
		UIView.animate(withDuration: 0.3,
					   delay: 0,
					   options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
					   animations: ({ [weak self] in
			self?.alpha = 1
			self?.transform = CGAffineTransform.identity
		}), completion: nil)
	}
	
	//open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
	//	NSLog("~~  \(TAG) | traitCollectionDidChange")
	//}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		// if touch.view != popupWindow {	// not work if view contain subview(s)
		if contentView != nil && !contentView.frame.contains(location) {
			dismissView(nil)
		}
	}
	
	@IBAction public func dismissView(_ sender: UIButton?) {
		dismissView(sender, completion: nil)
	}
	
	@objc public func dismissView(_ sender: UIButton?, completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: 0.25,
					   delay: 0,
					   options: [.curveEaseOut, .layoutSubviews, .allowAnimatedContent],
					   animations: ({ [weak self] in
			self?.alpha = 0
		})) { ok in
			super.removeFromSuperview()
			completion?()
		}
	}
	
	@objc public func test(_ noti: NSNotification) {
		NSLog("--  \(TAG) | test: \(type(of: self)) | \(self.hash)")
	}
}
