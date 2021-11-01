//
//  Created by Thang Nguyen on 9/27/21.
//

import UIKit

public class RoundedView : UIView {
	
	private let TAG = "◯"
	
	public override func layoutSubviews() {
		cornerRadiusRatio = cornerRadiusRatio == 0 ? 0.5 : cornerRadiusRatio
		
		super.layoutSubviews()
	}
}
