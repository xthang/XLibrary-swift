//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit

class PopupAlert: PopupView {
	
	@IBOutlet var title: UILabel!
	@IBOutlet var message: UILabel!
	@IBOutlet var buttons: UIStackView!
	
	
	static func initiate(title: String?, message: String?, preferredStyle: UIAlertController.Style) -> PopupAlert {
		let alert = UINib(nibName: "PopupAlert", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PopupAlert
		alert.title.text = title
		alert.message.text = message
		
		return alert
	}
	
	func addAction(title: String?, style: UIAlertAction.Style, handler: (() -> Void)?) {
		let btn = CustomButton()
		// btn.soundEnabled = false
		btn.setTitle(title, for: .normal)
		btn.titleLabel?.font = CommonConfig.font
		btn.setTitleColor(.darkGray, for: .normal)
		btn.setBackgroundImage(#imageLiteral(resourceName: "button"), for: .normal)
		btn.setBackgroundImage(#imageLiteral(resourceName: "button-pressed"), for: .highlighted)
		
		if #available(iOS 14.0, *) {
			btn.addAction(UIAction { [weak self] _ in
				self?.dismissView(sender: nil) {
					handler?()
				}
			}, for: .touchUpInside)
		} else {
			btn.addTarget(self, action: #selector(dismissView(sender:)), for: .touchUpInside)
			
			if let h = handler {
				@objc class ClosureSleeve: NSObject {
					let closure: (()->())?
					init(_ closure: (()->())?) {
						self.closure = closure
						//						super.init()
						//						NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIApplication.willEnterForegroundNotification, object: nil)
					}
					@objc func invoke() { closure?() }
					//					@objc func test(_ noti: NSNotification) {
					//						NSLog("!!- \(TAG) | ClosureSleeve activate: \(hash)")
					//					}
				}
				let sleeve = ClosureSleeve(h)
				objc_setAssociatedObject(self, UUID().uuidString, sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
				btn.addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: .touchUpInside)
			}
		}
		
		buttons.addArrangedSubview(btn)
	}
}