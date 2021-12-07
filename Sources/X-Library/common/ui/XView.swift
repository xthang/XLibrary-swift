//
//  Created by Thang Nguyen on 9/27/21.
//

import UIKit

public class XView : UIView {
	
	private let TAG = "\(XView.self)"
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		if cornerRadiusRatio != 0 { updateCorner("\(TAG)|layoutSubviews") }
		if shadowRadius != 0 { dropShadow("\(TAG)|layoutSubviews") }
	}
}
