//
//  Created by Thang Nguyen on 12/7/21.
//

import UIKit

public class PopupWindow: XView, Themable {
	
	public enum Style {
		case style1
		case style2
	}
	
	private var style: Style?
	
	init(style: Style) {
		self.style = style
		
		super.init(frame: .null)
		
		applyTheme("style", Theme.current)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public func applyTheme(_ tag: String, _ theme: Theme) {
		if style == .style1 {
			if let r = theme.settings.popupCornerRadiusRatio { cornerRadiusRatio = r }
			if let c = theme.settings.popupBackgroundColor { backgroundColor = c }
		}
	}
}
