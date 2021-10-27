//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit
import AVFoundation

open class PopupView: OverlayView {
	
	private let TAG = "PopupView"
	
	
	open override func willMove(toSuperview newSuperview: UIView?) {
		guard newSuperview != nil else { return }
		
		// alpha = 0
		contentView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
	}
	
	open override func didMoveToSuperview() {
		// NSLog("--  \(TAG) | Popup: didMoveToSuperview: \(hash)")
		super.didMoveToSuperview()
		if superview == nil { return }
		
		//		if #available(iOS 13.0, *) {
		//			NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIScene.willDeactivateNotification, object: window!.windowScene!)
		//		} else {
		//			NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIApplication.willResignActiveNotification, object: nil)
		//		}
		
		UIView.animate(withDuration: 0.3,
					   delay: 0,
					   usingSpringWithDamping: 0.6,
					   initialSpringVelocity: 0.5,
					   options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
					   animations: ({ [weak self] in
						// self?.alpha = 1
						self?.contentView.transform = CGAffineTransform.identity
					   }), completion: nil)
	}
	
	@objc public override func dismissView(_ sender: UIButton?, completion: (() -> Void)? = nil) {
		if Helper.soundOn { Singletons.instance.whooshSound?.play() }
		UIView.animate(withDuration: 0.15,
					   delay: 0,
					   options: [.curveEaseIn, .layoutSubviews, .allowAnimatedContent],
					   animations: ({ [weak self] in
						self?.alpha = 0
						self?.contentView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
					   })) { [weak self] _ in
			self?.removeFromSuperview()
			completion?()
		}
	}
}
