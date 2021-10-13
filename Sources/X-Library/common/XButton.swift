//
//  Created by Thang Nguyen on 7/4/21.
//

import UIKit

class XButton: UIButton {
	
	@IBInspectable var highlightedImage: UIImage? {
		didSet {
			setImage(highlightedImage, for: .highlighted)
		}
	}
	@IBInspectable var selectedImage: UIImage? {
		didSet {
			setImage(selectedImage, for: .selected)
		}
	}
	
	var soundEnabled: Bool = true
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		playSound()
		super.touchesEnded(touches, with: event)
	}
	
	func playSound() {
		if Helper.soundOn && soundEnabled { Singletons.btnSound?.play() }
	}
}

class CustomButton: XButton {
	
	@IBInspectable var highlightedBackgroundImage: UIImage? {
		didSet {
			setBackgroundImage(highlightedBackgroundImage, for: .highlighted)
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initiate()
	}
	
	init() {
		super.init(frame: .null)
		initiate()
		//		autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	func initiate() {
		if let bgImg = backgroundImage(for: .normal) {
			let img = bgImg.resizableImage(
				withCapInsets: UIEdgeInsets(top: bgImg.size.height * 0.5, left: bgImg.size.width * 0.5,
											bottom: bgImg.size.height * 0.5, right: bgImg.size.width * 0.5),
				resizingMode: .stretch)
			setBackgroundImage(img, for: .normal)
		}
		
		//		layer.borderWidth = 2;
		//		layer.borderColor = UIColor.green.cgColor;
	}
	
	override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
		let img = image?.resizableImage(
			withCapInsets: UIEdgeInsets(top: image!.size.height * 0.5, left: image!.size.width * 0.5,
										bottom: image!.size.height * 0.5, right: image!.size.width * 0.5),
			resizingMode: .stretch)
		super.setBackgroundImage(img, for: state)
	}
	
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// if !(self is SwitchButton) {
		UIView.animate(withDuration: 0,
					   delay: 0,
					   options: .allowUserInteraction,
					   animations: { [weak self] in
						self?.transform = CGAffineTransform(translationX: 0, y: 5)
					   }
		)
		super.touchesBegan(touches, with: event)
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		UIView.animate(withDuration: 0.1,
					   delay: 0,
					   options: .allowUserInteraction,
					   animations: { [weak self] in
						self?.transform = .identity
					   }
		)
		super.touchesEnded(touches, with: event)
	}
}

class TabButton: XButton {
	
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		UIView.animate(withDuration: 0,
					   delay: 0,
					   options: .allowUserInteraction,
					   animations: { [weak self] in
						self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
					   }
		)
		super.touchesBegan(touches, with: event)
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		transform = .identity
		super.touchesEnded(touches, with: event)
	}
	
	func onSelected() {
		transform = .identity
		UIView.animate(withDuration: 0.1,
					   delay: 0,
					   options: .allowUserInteraction,
					   animations: { [weak self] in
						self?.transform = CGAffineTransform(translationX: 0, y: (self?.frame.height ?? 0) * 0.20)
					   }
		)
	}
}
