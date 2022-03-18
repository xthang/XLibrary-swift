//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit

open class PopupAlert: PopupView {
	
	public enum Style: String {
		case style1
		case style2
	}
	public enum ButtonLayout: String {
		case style1
		case style2
		case style3
	}
	
	@IBOutlet var background: ScaleFrame?
	@IBOutlet var title: UILabel!
	@IBOutlet var message: UILabel!
	@IBOutlet public var buttons: UIStackView!
	
	private var buttonType: IXButton.Type = XButton.self
	
	open class func initiate(style: Style? = Theme.current.settings.popupStyle, title: String?, message: String?, fontName: String? = nil, buttonLayout: ButtonLayout? = nil, showCloseButton: Bool = false) -> PopupAlert {
		let alert = UINib(nibName: style == .style2 ? "PopupAlert2" : "PopupAlert", bundle: Bundle.module).instantiate(withOwner: nil, options: nil)[0] as! PopupAlert
		
		switch style {
			case .style2:
				if let fr = UIImage(named: "window_frame") { alert.background!.setResizedImage(image: fr) }
			default: break
		}
		
		if !showCloseButton {
			alert.closeBtn?.removeFromSuperview()
		}
		
		if title == nil { alert.title.isHidden = true }
		else { alert.title.text = title }
		if message == nil { alert.message.isHidden = true }
		else { alert.message.text = message }
		
		alert.title.font = UIFont(name: fontName ?? Theme.current.settings.fontName ?? CommonConfig.fontName, size: Theme.current.settings.fontSizeLarge1 ?? CommonConfig.fontSize)!
		alert.message.font = UIFont(name: fontName ?? Theme.current.settings.fontName ?? CommonConfig.fontName, size: Theme.current.settings.fontSizeLarge ?? CommonConfig.fontSize)!
		
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
	
	public func addAction(title: String?, layout: ButtonLayout? = Theme.current.settings.buttonLayout, style: ButtonStyle? = nil, icon: UIImage? = nil, cornerRadiusRatio: CGFloat? = nil, shadowRadius: CGFloat? = nil, handler: (() -> Void)? = nil) -> IXButton {
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
		
		// btn.soundEnabled = false
		btn.setTitle(title, for: .normal)
		btn.titleLabel?.font = UIFont(name: Theme.current.settings.fontName ?? CommonConfig.fontName, size: Theme.current.settings.buttonFontSize ?? CommonConfig.fontSize)!
		if btn is ImageButton {
			btn.setBackgroundImage(Theme.current.settings.buttonBackgroundImage!, for: .normal)
			btn.setBackgroundImage(Theme.current.settings.buttonHighlightedBackgroundImage!, for: .highlighted)
		}
		
		if btn is XButton2 {
			btn.setImage(icon, for: .normal)
		}
		
		if cornerRadiusRatio != nil { btn.cornerRadiusRatio = cornerRadiusRatio! }
		if shadowRadius != nil { btn.shadowRadius = shadowRadius! }
		
		if style != nil { btn.style = style }
		
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
		
		NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: Theme.current.settings.buttonHeight ?? 50).isActive = true
		
		buttons.addArrangedSubview(btn)
		
		return btn
	}
}
