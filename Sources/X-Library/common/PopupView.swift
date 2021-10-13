//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit
import AVFoundation

class PopupView: UIView {
	private let TAG = "PopupView"
	
	@IBOutlet var popupWindow: UIView!
	
	
	override func willMove(toSuperview newSuperview: UIView?) {
		guard newSuperview != nil else { return }
		
		// alpha = 0
		popupWindow.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
	}
	
	override func didMoveToSuperview() {
		// NSLog("--  \(TAG) | Popup: didMoveToSuperview: \(hash)")
		guard let view = superview else { return }
		
		//		if #available(iOS 13.0, *) {
		//			NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIScene.willDeactivateNotification, object: window!.windowScene!)
		//		} else {
		//			NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIApplication.willResignActiveNotification, object: nil)
		//		}
		
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalTo: view.heightAnchor),
			widthAnchor.constraint(equalTo: view.widthAnchor),
			topAnchor.constraint(equalTo: view.topAnchor),
			bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		
		UIView.animate(withDuration: 0.3,
					   delay: 0,
					   usingSpringWithDamping: 0.6,
					   initialSpringVelocity: 0.5,
					   options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
					   animations: ({ [weak self] in
						// self?.alpha = 1
						self?.popupWindow.transform = CGAffineTransform.identity
					   }), completion: nil)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		//		if touch.view != popupWindow {	// not work if view contain subview(s)
		if !popupWindow.frame.contains(location) {
			dismissView(sender: nil)
		}
	}
	
	@IBAction func dismissView(sender: UIButton?) {
		dismissView(sender: sender, completion: nil)
	}
	
	@objc func dismissView(sender: UIButton?, completion: (() -> Void)? = nil) {
		if Helper.soundOn { Singletons.whooshSound?.play() }
		UIView.animate(withDuration: 0.15,
					   delay: 0,
					   options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
					   animations: ({ [weak self] in
						self?.alpha = 0
						self?.popupWindow.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
					   })) { [weak self] _ in
			self?.removeFromSuperview()
			completion?()
		}
	}
	
	@objc func test(_ noti: NSNotification) {
		NSLog("--  \(TAG) | test: \(type(of: self)) | \(self.hash)")
	}
}
