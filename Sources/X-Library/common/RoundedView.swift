//
//  Created by Thang Nguyen on 9/27/21.
//

import UIKit

public class RoundedView : UIView {
	
	private let TAG = "◯"
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		cornerRadiusRatio = 0.5
	}
}
