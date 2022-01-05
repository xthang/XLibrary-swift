//
//  Created by Thang Nguyen on 7/4/21.
//

import UIKit

public enum ButtonStyle {
	case primary1
}

public protocol IXButton: UIControl, Themable {
	
	init()
	
	var style: ButtonStyle? { get set }
	
	// MARK: UIButton properties & methods
	
	var titleLabel: UILabel? { get }
	
	var imageView: UIImageView? { get }
	
	/// The label used to display the subtitle, when present.
	@available(iOS 15.0, *)
	var subtitleLabel: UILabel? { get }
	
	func setTitle(_ title: String?, for state: UIControl.State) // default is nil. title is assumed to be single line
	
	func setTitleColor(_ color: UIColor?, for state: UIControl.State) // default is nil. use opaque white
	
	func setTitleShadowColor(_ color: UIColor?, for state: UIControl.State) // default is nil. use 50% black
	
	func setImage(_ image: UIImage?, for state: UIControl.State) // default is nil. should be same size if different for different states
	
	func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) // default is nil
	
	@available(iOS 13.0, *)
	func setPreferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?, forImageIn state: UIControl.State)
	
	func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) // default is nil. title is assumed to be single line
	
	// MARK: X-Custom
	
	var highlightedColor: UIColor? { get set }
	var disabledColor: UIColor? { get set }
	
	var highlightedImage: UIImage? { get set }
	var selectedImage: UIImage? { get set }
	var highlightedBackgroundImage: UIImage? { get set }
	
	var soundEnabled: Bool { get set }
}

open class XButton: UIButton, IXButton {
	
	private let TAG = "\(XButton.self)"
	
	public var style: ButtonStyle? {
		didSet {
			applyStyle("didSet", style!)
		}
	}
	
	@IBInspectable public var highlightedColor: UIColor?
	private var temporaryBackgroundColor: UIColor?
	
	public override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				if temporaryBackgroundColor == nil {
					if let highlightedColor = highlightedColor {
						temporaryBackgroundColor = backgroundColor
						backgroundColor = highlightedColor
					}
				}
			} else {
				if let temporaryColor = temporaryBackgroundColor {
					backgroundColor = temporaryColor
					temporaryBackgroundColor = nil
				}
			}
		}
	}
	
	@IBInspectable public var disabledColor: UIColor?
	private var temporaryDiabledBackgroundColor: UIColor?
	
	public override var isEnabled: Bool {
		didSet {
			if !isEnabled {
				if temporaryDiabledBackgroundColor == nil {
					if let diabledColor = disabledColor {
						temporaryDiabledBackgroundColor = backgroundColor
						backgroundColor = diabledColor
					}
				}
			} else {
				if let temporaryColor = temporaryDiabledBackgroundColor {
					backgroundColor = temporaryColor
					temporaryDiabledBackgroundColor = nil
				}
			}
		}
	}
	
	@IBInspectable public var highlightedImage: UIImage? {
		didSet {
			setImage(highlightedImage, for: .highlighted)
		}
	}
	@IBInspectable public var selectedImage: UIImage? {
		didSet {
			setImage(selectedImage, for: .selected)
		}
	}
	@IBInspectable public var highlightedBackgroundImage: UIImage? {
		didSet {
			setBackgroundImage(highlightedBackgroundImage, for: .highlighted)
		}
	}
	
	@IBInspectable public var soundEnabled: Bool = true
	
	
	public required init() {
		super.init(frame: .zero)
		initiate("")
		
		translatesAutoresizingMaskIntoConstraints = false
		applyTheme("", Theme.current)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		initiate("coder")
	}
	
	internal func initiate(_ tag: String) {
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		if cornerRadiusRatio != 0 { updateCorner("layoutSubviews") }
		if shadowRadius != 0 { dropShadow(TAG) }
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		if bounds.contains(location) {
			playSound()
		}
		super.touchesEnded(touches, with: event)
	}
	
	public func applyTheme(_ tag: String, _ theme: Theme) {
		if let c = theme.settings.buttonBackgroundColor { backgroundColor = c }
		if let c = theme.settings.buttonHighlightedBackgroundColor { highlightedColor = c }
		if let c = theme.settings.buttonDisabledBackgroundColor { disabledColor = c }
		
		if let c = theme.settings.buttonTextColor { setTitleColor(c, for: .normal) }
		if let c = theme.settings.buttonHighlightedTextColor { setTitleColor(c, for: .highlighted) }
		if let c = theme.settings.buttonDisabledTextColor { setTitleColor(c, for: .disabled) }
		
		if let r = theme.settings.buttonCornerRadiusRatio { cornerRadiusRatio = r }
		
		if let r = theme.settings.buttonShadowRadius { shadowRadius = r }
		if let c = theme.settings.buttonShadowColor { shadowColor = c }
	}
	
	func applyStyle(_ tag: String, _ style: ButtonStyle) {
		switch style {
			case .primary1:
				backgroundColor = Theme.current.settings.buttonPrimary1BackgroundColor!
				setTitleColor(Theme.current.settings.buttonPrimary1TextColor!, for: .normal)
		}
	}
	
	func playSound() {
		if Helper.soundOn && soundEnabled { Singletons.instance.btnSound?.play() }
	}
}

public class ImageButton: XButton {
	
	override func initiate(_ tag: String) {
		super.initiate(tag)
		
		if let img = backgroundImage(for: .normal) {
			setBackgroundImage(img, for: .normal)
		}
		
		//		layer.borderWidth = 2;
		//		layer.borderColor = UIColor.green.cgColor;
	}
	
	public override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
		let img = image?.resizableImage(
			withCapInsets: UIEdgeInsets(top: image!.size.height * 0.5, left: image!.size.width * 0.5,
												 bottom: image!.size.height * 0.5, right: image!.size.width * 0.5),
			resizingMode: .stretch)
		super.setBackgroundImage(img, for: state)
	}
	
	public override func applyTheme(_ tag: String, _ theme: Theme) {
		if let c = theme.settings.buttonTextColor { setTitleColor(c, for: .normal) }
		if let c = theme.settings.buttonHighlightedTextColor { setTitleColor(c, for: .highlighted) }
		if let c = theme.settings.buttonDisabledTextColor { setTitleColor(c, for: .disabled) }
		
		if let r = theme.settings.buttonShadowRadius { shadowRadius = r }
		if let c = theme.settings.buttonShadowColor { shadowColor = c }
	}
	
	internal override func applyStyle(_ tag: String, _ style: ButtonStyle) {
		switch style {
			case .primary1:
				setBackgroundImage(Theme.current.settings.buttonPrimary1BackgroundImage!, for: .normal)
				setTitleColor(Theme.current.settings.buttonPrimary1TextColor!, for: .normal)
		}
	}
	
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// if !(self is SwitchButton) {
		UIView.animate(withDuration: 0,
							delay: 0,
							options: .allowUserInteraction,
							animations: { [weak self] in
			self?.transform = CGAffineTransform(translationX: 0, y: 5)
		})
		super.touchesBegan(touches, with: event)
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		UIView.animate(withDuration: 0.1,
							delay: 0,
							options: .allowUserInteraction,
							animations: { [weak self] in
			self?.transform = .identity
		})
		super.touchesEnded(touches, with: event)
	}
}

public class TabButton: XButton {
	
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		UIView.animate(withDuration: 0,
							delay: 0,
							options: .allowUserInteraction,
							animations: { [weak self] in
			self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		})
		super.touchesBegan(touches, with: event)
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		transform = .identity
		super.touchesEnded(touches, with: event)
	}
	
	public func onSelected() {
		transform = .identity
		UIView.animate(withDuration: 0.1,
							delay: 0,
							options: .allowUserInteraction,
							animations: { [weak self] in
			self?.transform = CGAffineTransform(translationX: 0, y: (self?.frame.height ?? 0) * 0.20)
		})
	}
}

open class XButton2: UIControl, IXButton {
	
	private let TAG = "\(XButton2.self)"
	
	public var style: ButtonStyle? {
		didSet {
			switch style {
				case .primary1:
					backgroundColor = Theme.current.settings.buttonPrimary1BackgroundColor!
					setTitleColor(Theme.current.settings.buttonPrimary1TextColor!, for: .normal)
				default: break
			}
		}
	}
	
	private let stackView = UIStackView()
	private let imageContainer = UIView()
	private let titleContainer = UIView()
	
	public var titleLabel: UILabel?
	
	public var imageView: UIImageView?
	
	public var subtitleLabel: UILabel?
	
	@IBInspectable public var highlightedColor: UIColor?
	private var temporaryBackgroundColor: UIColor?
	
	public override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				if temporaryBackgroundColor == nil {
					if let highlightedColor = highlightedColor {
						temporaryBackgroundColor = backgroundColor
						backgroundColor = highlightedColor
					}
				}
			} else {
				if let temporaryColor = temporaryBackgroundColor {
					backgroundColor = temporaryColor
					temporaryBackgroundColor = nil
				}
			}
		}
	}
	
	@IBInspectable public var disabledColor: UIColor?
	private var temporaryDiabledBackgroundColor: UIColor?
	
	public override var isEnabled: Bool {
		didSet {
			if !isEnabled {
				if temporaryDiabledBackgroundColor == nil {
					if let diabledColor = disabledColor {
						temporaryDiabledBackgroundColor = backgroundColor
						backgroundColor = diabledColor
					}
				}
			} else {
				if let temporaryColor = temporaryDiabledBackgroundColor {
					backgroundColor = temporaryColor
					temporaryDiabledBackgroundColor = nil
				}
			}
		}
	}
	
	@IBInspectable public var highlightedImage: UIImage? {
		didSet {
			setImage(highlightedImage, for: .highlighted)
		}
	}
	@IBInspectable public var selectedImage: UIImage? {
		didSet {
			setImage(selectedImage, for: .selected)
		}
	}
	@IBInspectable public var highlightedBackgroundImage: UIImage? {
		didSet {
			setBackgroundImage(highlightedBackgroundImage, for: .highlighted)
		}
	}
	
	@IBInspectable public var soundEnabled: Bool = true
	
	public required init() {
		super.init(frame: .zero)
		initiate("")
		
		translatesAutoresizingMaskIntoConstraints = false
		applyTheme("", Theme.current)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		initiate("coder")
	}
	
	internal func initiate(_ tag: String) {
		stackView.isUserInteractionEnabled = false // pass the events through to UIControl
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.distribution = .fill
		stackView.spacing = 7
		stackView.alignment = .fill
		// stackView.backgroundColor = .cyan
		
		stackView.addArrangedSubview(imageContainer)
		stackView.addArrangedSubview(titleContainer)
		
		addSubview(stackView)
		NSLayoutConstraint.activate([
			NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0),
			NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.6, constant: 0),
		])
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		if cornerRadiusRatio != 0 { updateCorner("layoutSubviews") }
		if shadowRadius != 0 { dropShadow(TAG) }
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		if bounds.contains(location) {
			playSound()
		}
		super.touchesEnded(touches, with: event)
	}
	
	open func setTitle(_ title: String?, for state: UIControl.State) {
		let container = titleContainer
		
		if title == nil {
			if !container.subviews.isEmpty {
				container.subviews[0].removeFromSuperview()
				titleLabel = nil
			}
		} else {
			if titleLabel == nil {
				titleLabel = UILabel()
				titleLabel!.translatesAutoresizingMaskIntoConstraints = false
				container.addSubview(titleLabel!)
				NSLayoutConstraint.activate([
					NSLayoutConstraint(item: titleLabel!, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: titleLabel!, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: titleLabel!, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: titleLabel!, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.7, constant: 0)
				])
			}
			titleLabel!.text = title
		}
	}
	
	open func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
		// TODO: this
		titleLabel?.textColor = color
	}
	
	open func setTitleShadowColor(_ color: UIColor?, for state: UIControl.State) {
		
	}
	
	open func setImage(_ image: UIImage?, for state: UIControl.State) {
		let container = imageContainer
		
		if image == nil {
			if !container.subviews.isEmpty {
				container.subviews[0].removeFromSuperview()
				imageView = nil
			}
		} else {
			if imageView == nil {
				imageView = UIImageView(image: image)
				imageView!.translatesAutoresizingMaskIntoConstraints = false
				container.addSubview(imageView!)
				NSLayoutConstraint.activate([
					NSLayoutConstraint(item: imageView!, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: imageView!, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: imageView!, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: imageView!, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: imageView!, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1, constant: 0)
				])
			} else {
				imageView!.image = image
			}
		}
	}
	
	open func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
		
	}
	
	@available(iOS 13.0, *)
	public func setPreferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?, forImageIn state: UIControl.State) {
		
	}
	
	open func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
		
	}
	
	public func applyTheme(_ tag: String, _ theme: Theme) {
		if let c = theme.settings.buttonBackgroundColor { backgroundColor = c }
		if let c = theme.settings.buttonHighlightedBackgroundColor { highlightedColor = c }
		if let c = theme.settings.buttonDisabledBackgroundColor { disabledColor = c }
		
		if let c = theme.settings.buttonTextColor { setTitleColor(c, for: .normal) }
		if let c = theme.settings.buttonHighlightedTextColor { setTitleColor(c, for: .highlighted) }
		if let c = theme.settings.buttonDisabledTextColor { setTitleColor(c, for: .disabled) }
		
		if let r = theme.settings.buttonCornerRadiusRatio { cornerRadiusRatio = r }
		
		if let r = theme.settings.buttonShadowRadius { shadowRadius = r }
		if let c = theme.settings.buttonShadowColor { shadowColor = c }
	}
	
	func playSound() {
		if Helper.soundOn && soundEnabled { Singletons.instance.btnSound?.play() }
	}
}
