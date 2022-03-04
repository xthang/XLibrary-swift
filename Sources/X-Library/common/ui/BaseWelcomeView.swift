//
//  Created by Thang Nguyen on 03/04/22.
//

import UIKit

open class BaseWelcomeView: OverlayView {
	
	private let TAG = "WC"
	
	public var completion: (() -> Void)?
	
	public func onCompletion(completion: @escaping () -> Void) {
		self.completion = completion
	}
	
	@IBAction public func getStartedButtonTapped(_ sender: UIButton) {
		self.removeFromSuperview()
		// UserDefaults.standard.setValue(Helper.appVersion, forKey: CommonConfig.Keys.welcomeVersion)
		completion?()
	}
}
