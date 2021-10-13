//
//  Created by Thang Nguyen on 9/27/21.
//

import UIKit

class RoundedView : UIView {
	
	private let TAG = "◯"
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		cornerRadiusRatio = 0.5
	}
}
