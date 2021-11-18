//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit

public class PopupAlert: PopupView {
	
	public enum UIType {
		case type1
		case type2
	}
	public enum ButtonType {
		case type1
		case type2
	}
	
	@IBOutlet var title: UILabel!
	@IBOutlet var message: UILabel!
	@IBOutlet public var buttons: UIStackView!
	
	var buttonType: XButton.Type = XButton.self
	
	public static func initiate(type: UIType, title: String?, message: String?, preferredStyle: UIAlertController.Style, buttonType: ButtonType? = nil) -> PopupAlert {
		let alert = UINib(nibName: type == .type1 ? "PopupAlert" : "PopupAlert2", bundle: Bundle.module).instantiate(withOwner: nil, options: nil)[0] as! PopupAlert
		alert.title.text = title
		alert.message.text = message
		
		switch buttonType {
			case .type2:
				alert.buttonType = CustomButton.self
			default:
				break
		}
		
		return alert
	}
	
	public func addAction(title: String?, style: UIAlertAction.Style, handler: (() -> Void)?) {
		let btn = buttonType.init()
		// btn.soundEnabled = false
		btn.setTitle(title, for: .normal)
		btn.titleLabel?.font = CommonConfig.font
		btn.setTitleColor(.darkGray, for: .normal)
		if buttonType == CustomButton.self {
			btn.setBackgroundImage(#imageLiteral(resourceName: "button"), for: .normal)
			btn.setBackgroundImage(#imageLiteral(resourceName: "button-pressed"), for: .highlighted)
		} else {
			btn.cornerRadiusRatio = 0.1
			btn.backgroundColor = .buttonBackground
			btn.highlightedColor = .buttonHighlightedBackground
			btn.diabledColor = .buttonDisabledBackground
		}
		
		if #available(iOS 14.0, *) {
			btn.addAction(UIAction { [weak self, weak btn] _ in
				self?.dismissView(btn) {
					handler?()
				}
			}, for: .touchUpInside)
		} else {
			// btn.addTarget(self, action: #selector(dismissView(_:)), for: .touchUpInside)
			
			@objc class ClosureSleeve: NSObject {
				let closure: (()->())?
				init(_ closure: (()->())?) {
					self.closure = closure
					// super.init()
					// NotificationCenter.default.addObserver(self, selector: #selector(self.test), name: UIApplication.willEnterForegroundNotification, object: nil)
				}
				@objc func invoke() { closure?() }
				// @objc func test(_ noti: NSNotification) {
				// 	NSLog("!!- \(TAG) | ClosureSleeve activate: \(hash)")
				// }
			}
			let sleeve = ClosureSleeve({ [weak self, weak btn] in
				self?.dismissView(btn) {
					handler?()
				}
			})
			objc_setAssociatedObject(self, UUID().uuidString, sleeve, .OBJC_ASSOCIATION_RETAIN)
			btn.addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: .touchUpInside)
		}
		
		NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: 50).isActive = true
		
		buttons.addArrangedSubview(btn)
	}
}
