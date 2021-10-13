import UIKit
import SpriteKit
import GameKit
import AuthenticationServices

import GoogleMobileAds


extension Notification.Name {
	static let sound = Notification.Name(rawValue: "sound")
	static let soundVolume = Notification.Name(rawValue: "sound-volume")
	static let music = Notification.Name(rawValue: "music")
	static let musicVolume = Notification.Name(rawValue: "music-volume")
	static let vibration = Notification.Name(rawValue: "vibration")
	
	static let xAuthStateChanged = Notification.Name(rawValue: "xAuthStateChanged")
	
	static let presentGame = Notification.Name(rawValue: "presentGame")
	static let gcAuthenticationChanged = Notification.Name(rawValue: "gcAuthenticationChanged")
	
	static let appleIDStateChanged = Notification.Name(rawValue: "appleIDStateChanged")
	static let fbStateChanged = Notification.Name(rawValue: "fbStateChanged")
	static let eosLoginStatusChanged = Notification.Name(rawValue: "eosLoginStatusChanged")
}

extension UIControl.Event {
	public static let valueChangedEnded = UIControl.Event(rawValue: UInt())
}

public extension UIDevice {
	
	static let modelID: String = {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		// NSLog("--  i: identifier: \(identifier)")
		
		return identifier
	}()
}

extension UIColor {
	static var background: UIColor {
		return UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
	}
	
	static var sky: UIColor {
		return UIColor(red: 112/255, green: 196/255, blue: 254/255, alpha: 1)
	}
}

extension UIWindow {
	open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			if var topController = rootViewController {
				while let presentedViewController = topController.presentedViewController {
					topController = presentedViewController
				}
				// topController should now be your topmost view controller
				
				GADMobileAds.sharedInstance().presentAdInspector(from: topController) { error in
					NSLog("!-  UIWindow | motionEnded -~> gAd Inspector: error: \(error?.localizedDescription as Any)")
				}
			}
		}
	}
}

extension UIView {
	//	@IBInspectable public var borderWidth: CGFloat {
	//		get {
	//			return layer.borderWidth
	//		}
	//		set {
	//			layer.borderWidth = newValue
	//		}
	//	}
	
	/// The ratio (from 0.0 to 1.0, inclusive) of the view's corner radius
	/// to its width. For example, a 50% radius would be specified with
	/// `cornerRadiusRatio = 0.5`.
	@IBInspectable public var cornerRadiusRatio: CGFloat {
		get {
			return layer.cornerRadius / frame.width
		}
		set {
			// Make sure that it's between 0.0 and 1.0. If not, restrict it to that range.
			let normalizedRatio = max(0.0, min(1.0, newValue))
			layer.cornerRadius = frame.width * normalizedRatio
		}
	}
}

extension UIImageView {
	static let TAG = "UIImageView"
	
	func fromGif(resourceName: String, ofType: String) {
		guard let path = Bundle.main.path(forResource: resourceName, ofType: ofType) else {
			NSLog("--  \(UIImageView.TAG) | Gif does not exist at path: \(resourceName) | \(ofType)")
			return
		}
		let url = URL(fileURLWithPath: path)
		guard let gifData = try? Data(contentsOf: url),
			  let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else {
				  NSLog("--  \(UIImageView.TAG) | gifData / source is nil")
				  return
			  }
		var images = [UIImage]()
		let imageCount = CGImageSourceGetCount(source)
		for i in 0 ..< imageCount {
			if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
				images.append(UIImage(cgImage: image))
			}
		}
		animationImages = images
	}
	
	func loadSpinner() {
		fromGif(resourceName: "spinner-icon-gif", ofType: "jpg")
	}
	
	func downloadImage(from url: URL, completion: @escaping (_ ok: Bool) -> Void) {
		URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
			guard let data = data, error == nil, !data.isEmpty else {
				NSLog("--> image download fail: %@ | %@ | %@", response?.suggestedFilename ?? url.lastPathComponent, error?.localizedDescription ?? "--", data != nil ? String(data!.count) : "--")
				DispatchQueue.main.async() {
					completion(false)
				}
				return
			}
			DispatchQueue.main.async() { [weak self] in
				self?.image = UIImage(data: data)
			}
		}).resume()
	}
}

extension UIImage {
	func resizeTopAlignedToFill(_ containerWidth: CGFloat) -> UIImage? {
		let newHeight = containerWidth * size.height / size.width
		let newSize = CGSize(width: containerWidth, height: newHeight)
		
		UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
		draw(in: CGRect(origin: .zero, size: newSize))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
}

extension SKScene {
	@objc func doPressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {}
}

extension GKError {
	var content: String {
		switch code {
			case .notAuthenticated, .notAuthorized, .userDenied, .invalidCredentials:
				return NSLocalizedString("Local player has not been authenticated", comment: "")
			case .invalidPlayer, .playerStatusInvalid:
				return NSLocalizedString("Local player is invalid", comment: "")
			case .gameUnrecognized:
				return NSLocalizedString("Game Unrecognized", comment: "")
			case .connectionTimeout:
				return NSLocalizedString("Connection Timeout", comment: "")
			default:
				return NSLocalizedString("Something is wrong [\(code.rawValue)]", comment: "")
		}
	}
}

@available(iOS 13.0, *)
extension ASAuthorizationAppleIDProvider.CredentialState {
	func toPartnerState() -> Partner.CredentialState {
		switch self {
			case .revoked: return .revoked
			case .authorized: return .authorized
			case .notFound: return .notFound
			case .transferred: return .transferred
			default: return .undefined
				
		}
	}
}
