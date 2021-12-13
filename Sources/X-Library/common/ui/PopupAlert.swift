//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit

public class PopupAlert: PopupView {
	
	public enum Style {
		case style1
		case style2
	}
	public enum ButtonLayout {
		case style1
		case style2
		case style3
	}
	
	private var font = UIFont(name: CommonConfig.fontName, size: 19)!
	
	@IBOutlet var title: UILabel!
	@IBOutlet var message: UILabel!
	@IBOutlet public var buttons: UIStackView!
	
	private var buttonType: IXButton.Type = XButton.self
	
	open class func initiate(style: Style? = nil, title: String?, message: String?, font: UIFont? = nil, buttonLayout: ButtonLayout? = nil, showCloseButton: Bool = false) -> PopupAlert {
		let alert = UINib(nibName: style == .style2 ? "PopupAlert2" : "PopupAlert", bundle: Bundle.module).instantiate(withOwner: nil, options: nil)[0] as! PopupAlert
		
		if !showCloseButton {
			alert.closeBtn?.removeFromSuperview()
		}
		
		if title == nil { alert.title.isHidden = true }
		else { alert.title.text = title }
		if message == nil { alert.message.isHidden = true }
		else { alert.message.text = message }
		
		if font != nil {
			alert.font = font!
			alert.title.font = font
			alert.message.font = font
		}
		
		switch buttonLayout {
			case .style2:
				alert.buttonType = ImageButton.self
			case .style3:
				alert.buttonType = XButton2.self
			default:
				break
		}
		
		return alert
	}
	
	public func addAction(title: String?, layout: ButtonLayout? = nil, style: ButtonStyle? = nil, icon: UIImage? = nil, cornerRadiusRatio: CGFloat? = nil, shadowRadius: CGFloat? = nil, handler: (() -> Void)? = nil) -> IXButton {
		let buttonType: IXButton.Type
		switch layout {
			case .style1:
				buttonType = XButton.self
			case .style2:
				buttonType = ImageButton.self
			case .style3:
				buttonType = XButton2.self
			default:
				buttonType = self.buttonType
		}
		
		let btn = buttonType.init()
		if style != nil { btn.style = style }
		
		// btn.soundEnabled = false
		btn.setTitle(title, for: .normal)
		btn.titleLabel?.font = font
		if btn is ImageButton {
			btn.setBackgroundImage(#imageLiteral(resourceName: "button"), for: .normal)
			btn.setBackgroundImage(#imageLiteral(resourceName: "button-pressed"), for: .highlighted)
		}
		
		if btn is XButton2 {
			btn.setImage(icon, for: .normal)
		}
		
		if cornerRadiusRatio != nil { btn.cornerRadiusRatio = cornerRadiusRatio! }
		if shadowRadius != nil { btn.shadowRadius = shadowRadius! }
		
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
		
		return btn
	}
}
