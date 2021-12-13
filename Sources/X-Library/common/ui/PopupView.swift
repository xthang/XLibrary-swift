//
//  Created by Thang Nguyen on 7/27/21.
//

import UIKit
import AVFoundation

open class PopupView: OverlayView {
	
	private let TAG = "\(PopupView.self)"
	
	@IBOutlet public var closeBtn: BaseSceneButton?
	
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		animationStyle = .scale
		
		dismissSoundEnabled = true
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		if let sr = Theme.current.settings.popupShadowRadius { contentView!.shadowRadius = sr }
		
		// closeBtn is assigned only after awakeFromNib
		if let closeIcon = UIImage(named: "close") {
			closeBtn?.setImage(closeIcon, for: .normal)
		}
		closeBtn?.soundEnabled = false
	}
}
