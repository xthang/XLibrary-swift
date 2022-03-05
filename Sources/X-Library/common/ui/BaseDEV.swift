//
//  Created by Thang Nguyen on 11/21/21.
//

import UIKit

open class BaseDEV: PopupView {
	
	private let TAG = "\(BaseDEV.self)"
	
	private var keyboardConstraint: NSLayoutConstraint!
	
	@IBOutlet public weak var info: UILabel!
	
	@IBOutlet public weak var levelTextField: UITextField!
	
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		animationStyle = .fade
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		info.text = "INFO:"
		info.text! += "\n- appInstallVersion: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.appInstallVersion) ?? "--")"
		info.text! += "\n- appDataVersion: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.appDataVersion) ?? "--")"
		// info.text! += "\n- welcomeVersion: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.welcomeVersion) ?? "--")"
		info.text! += "\n- newAppUpdateNotiVersion: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.newAppUpdateNotiVersion) ?? "--")"
		info.text! += "\n"
		info.text! += "\n- appOpenCount: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.appOpenCount) ?? "--")"
		info.text! += "\n- sessionsCount: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.sessionsCount) ?? "--")"
		info.text! += "\n- gamesCount: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.gamesCount) ?? "--")"
		info.text! += "\n- bestScore: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.bestScore) ?? "--")"
		info.text! += "\n"
		info.text! += "\n- gameCenterPlayerInfo: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.gameCenterPlayerInfo) ?? "--")"
		info.text! += "\n"
		info.text! += "\n- coinCount: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.coinCount) ?? "--")"
		info.text! += "\n- purchased: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.purchased) ?? "--")"
		info.text! += "\n- lastDailyRewardingTime: \(UserDefaults.standard.object(forKey: CommonConfig.Keys.lastDailyRewardingTime) ?? "--")"
		info.text! += "\n"
		let userDefaults = UserDefaults.standard.dictionaryRepresentation().filter({ (key, value) in
			return ![
				CommonConfig.Keys.appInstallVersion,
				CommonConfig.Keys.appDataVersion,
				CommonConfig.Keys.newAppUpdateNotiVersion,
				CommonConfig.Keys.appOpenCount,
				CommonConfig.Keys.sessionsCount,
				CommonConfig.Keys.gamesCount,
				CommonConfig.Keys.bestScore,
				CommonConfig.Keys.gameCenterPlayerInfo,
				CommonConfig.Keys.coinCount,
				CommonConfig.Keys.purchased,
				CommonConfig.Keys.lastDailyRewardingTime,
			].contains(key)
		})
		info.text! += "\n- UserDefaults: \(userDefaults)"
		info.text! += "\n-------------------------------------------------\n"
		
		keyboardConstraint = NSLayoutConstraint(item: contentView!,
															 attribute: .bottom,
															 relatedBy: .lessThanOrEqual,
															 toItem: self,
															 attribute: .bottom,
															 multiplier: 1,
															 constant: 0)
		keyboardConstraint.isActive = false
	}
	
	// MARK: - Lifecycle
	
	open override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		if superview != nil {
			NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
		} else {
			NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		}
	}
	
	@objc private func keyboardWillShowNotification(_ notification: NSNotification) {
		let userInfo = notification.userInfo!
		
		let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
		let keyboardFrame = keyboardSize.cgRectValue
		if !keyboardConstraint.isActive {
			keyboardConstraint.constant = -keyboardFrame.height - frame.height / 20
			keyboardConstraint.isActive = true
		}
	}
	
	@objc private func keyboardWillHideNotification(notification: NSNotification) {
		if keyboardConstraint.isActive {
			keyboardConstraint.isActive = false
		}
	}
	
	@IBAction func hideDevBtn(_ sender: UIButton) {
		print("--  \(TAG) | hideDevBtn ...")
		
		(viewController as! BaseViewController).devBtn.isHidden = true
	}
	
	@IBAction open func reset(_ sender: UIButton) {
		print("--  \(TAG) | reset ...")
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.appDataVersion)
		// UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.welcomeVersion)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.newAppUpdateNotiVersion)
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.gamesCount)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.gameLevel)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.bestScore)
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.gameCenterPlayerInfo)
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.coinCount)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.purchased)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.lastDailyRewardingTime)
		
		Snackbar.s("RESET DONE")
	}
	
	@IBAction func resetWelcome(_ sender: UIButton) {
		print("--  \(TAG) | resetWelcome ...")
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.newAppUpdateNotiVersion)
		
		Snackbar.s("resetWelcome DONE")
	}
	
	@IBAction func resetNewAppUpdateNoti(_ sender: UIButton) {
		print("--  \(TAG) | resetNewAppUpdateNoti ...")
		
		UserDefaults.standard.setValue("x.x.x", forKey: CommonConfig.Keys.newAppUpdateNotiVersion)
		
		Snackbar.s("resetNewAppUpdateNoti DONE")
	}
	
	@IBAction open func setLevel(_ sender: UIButton) {
		print("--  \(TAG) | setLevel ...")
	}
	
	public func resizeImageToFit(_ tag: String, _ originalImage: UIImage, size: CGSize, aspect: Float) -> UIImage {
		let scale = min(size.width / originalImage.size.width, size.height / originalImage.size.height)
		let resizedImage = originalImage.resized(to: CGSize(width: originalImage.size.width * scale, height: originalImage.size.height * scale))
		
		let horizontalInset = aspect > 1 ? resizedImage.size.width * 0.5 : 0
		let verticalInset = aspect > 1 ? 0 : resizedImage.size.height * 0.5
		let stretchedImg = resizedImage.resizableImage(
			withCapInsets: UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset),
			resizingMode: .stretch)
		
		print("--  resizeImageToFit [\(tag)]: \(originalImage.size) -> \(resizedImage.size) ~ \(stretchedImg.size)")
		
		return stretchedImg
	}
	
	@IBAction open func saveLogo(_ sender: UIButton) {}
	
	@IBAction open func saveImage(_ sender: UIButton) {}
	
	@objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			let alert = PopupAlert.initiate(title: "Save error", message: error.localizedDescription)
			addSubview(alert)
		} else {
			Snackbar.s("Your image has been saved to your photos")
		}
	}
}
