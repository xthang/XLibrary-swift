//
//  Created by Thang Nguyen on 7/29/21.
//

import UIKit

//@IBDesignable
public class XSlider: UIControl {
	private let TAG = "XSlider"
	
	public override var bounds: CGRect {	// frame not update immediately when rotate
		didSet {
			updateLayerFrames(1)
		}
	}
	
	@IBInspectable public var value: CGFloat = 0.8 {
		didSet {
			updateLayerFrames(2)
		}
	}
	
	public var isInactive: Bool = false {
		didSet {
			alpha = isInactive ? 0.5 : 1
		}
	}
	
	static let defaultThumb = Helper.circle(diameter: 30, color: .white)
	
	private let thumbImageView = UIImageView()
	@IBInspectable public var thumbImage: UIImage? {
		didSet {
			thumbImageView.image = thumbImage
		}
	}
	@IBInspectable public var highlightedThumbImage: UIImage? {
		didSet {
			thumbImageView.highlightedImage = highlightedThumbImage
		}
	}
	@IBInspectable public var thumbColor: UIColor? {
		didSet {
			thumbImageView.image = (thumbColor != nil) ? Helper.circle(diameter: 30, color: thumbColor!) : XSlider.defaultThumb
		}
	}
	
	private let trackLine = UIImageView()
	@IBInspectable public var trackLineColor: UIColor? {
		didSet {
			trackLine.backgroundColor = trackLineColor
		}
	}
	@IBInspectable public var trackLineImage: UIImage? {
		didSet {
			trackLine.image = trackLineImage
		}
	}
	@IBInspectable public var trackLineHeightPercent: CGFloat = 0.3 {
		didSet {
		}
	}
	
	private let trackLineInd = UIImageView()
	@IBInspectable var trackLineIndColor: UIColor? {
		didSet {
			trackLineInd.backgroundColor = trackLineIndColor
		}
	}
	@IBInspectable public var trackLineIndImage: UIImage? {
		didSet {
			trackLineInd.image = trackLineIndImage
		}
	}
	@IBInspectable public var trackLineIndHeightPercent: CGFloat = 0.3 {
		didSet {
		}
	}
	
	@IBInspectable public var trackLineInsetPerThumb: CGFloat = 0
	
	
	public override func awakeFromNib() {
		// NSLog("--  \(TAG) | xS: awakeFromNib")
		super.awakeFromNib()
		
		setupView(0)
		updateLayerFrames(0)
	}
	
	public override func prepareForInterfaceBuilder() {
		NSLog("--  \(TAG) | xS: prepareForInterfaceBuilder")
		super.prepareForInterfaceBuilder()
		
		setupView(-1)
		updateLayerFrames(-1)
	}
	
	private func setupView(_ tag: Int) {
		// NSLog("~~  \(TAG) | xS: setupView: \(tag) | \(trackLineImage) | \(trackLineIndImage)")
		trackLine.layer.cornerRadius = 4
		trackLine.backgroundColor = trackLineColor ?? (trackLineImage == nil ? .lightGray.withAlphaComponent(0.7) : nil)
		trackLine.image = trackLineImage
		addSubview(trackLine)
		
		trackLineInd.layer.cornerRadius = 4
		trackLineInd.backgroundColor = trackLineIndColor ?? (trackLineIndImage == nil ? tintColor : nil)
		trackLineInd.image = trackLineIndImage
		addSubview(trackLineInd)
		
		thumbImageView.image = thumbImage ?? ((thumbColor != nil) ? Helper.circle(diameter: 30, color: thumbColor!) : XSlider.defaultThumb)
		thumbImageView.highlightedImage = highlightedThumbImage
		addSubview(thumbImageView)
	}
	
	private func updateLayerFrames(_ tag: Int) {
		// NSLog("~~  \(TAG) | xS: updateLayerFrames: \(tag) | \(value) | \(frame) | \(bounds)")
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		let thumbHeight = min(bounds.height, bounds.width)
		let thumbWidth = thumbHeight * ((thumbImageView.image != nil) ? (thumbImageView.image!.size.width / thumbImageView.image!.size.height) : 1)
		thumbImageView.frame = CGRect(x: (bounds.width - thumbWidth) * value, y: (bounds.height - thumbHeight) / 2,
									  width: thumbWidth, height: thumbHeight)
		
		trackLine.frame = bounds.insetBy(dx: thumbImageView.frame.width/2 * trackLineInsetPerThumb, dy: bounds.height * (1 - trackLineHeightPercent)/2)
		//		trackLayer.setNeedsDisplay()
		trackLineInd.frame = bounds.inset(by: UIEdgeInsets(top: bounds.height * (1 - trackLineIndHeightPercent)/2,
														   left: thumbImageView.frame.width/2 * trackLineInsetPerThumb,
														   bottom: bounds.height * (1 - trackLineIndHeightPercent)/2,
														   right: bounds.width - thumbImageView.frame.origin.x - thumbImageView.frame.width/2))
		//		trackLayerOn.setNeedsDisplay()
		
		CATransaction.commit()
	}
	
	public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let loc = touch.location(in: self)
		
		if thumbImageView.frame.contains(loc) {
			thumbImageView.isHighlighted = true
		}
		
		return thumbImageView.isHighlighted
	}
	
	public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		
		if thumbImageView.isHighlighted {
			value = max(0, min(1, location.x / bounds.width))
		}
		sendActions(for: .valueChanged)
		
		return true
	}
	
	public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		thumbImageView.isHighlighted = false
		sendActions(for: .valueChanged)
	}
}
