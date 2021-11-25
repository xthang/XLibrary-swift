import UIKit
import SpriteKit
import GameKit
import AuthenticationServices
import StoreKit

import GoogleMobileAds


extension Date {
	
	func formatted(_ format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
	
	public static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
	}
}
extension Notification.Name {
	
	public static let sound = Notification.Name(rawValue: "sound")
	public static let soundVolume = Notification.Name(rawValue: "sound-volume")
	public static let music = Notification.Name(rawValue: "music")
	public static let musicVolume = Notification.Name(rawValue: "music-volume")
	public static let vibration = Notification.Name(rawValue: "vibration")
	
	public static let xAuthStateChanged = Notification.Name(rawValue: "xAuthStateChanged")
	
	public static let presentGame = Notification.Name(rawValue: "presentGame")
	public static let gcAuthenticationChanged = Notification.Name(rawValue: "gcAuthenticationChanged")
	
	public static let appleIDStateChanged = Notification.Name(rawValue: "appleIDStateChanged")
	public static let fbStateChanged = Notification.Name(rawValue: "fbStateChanged")
	public static let eosLoginStatusChanged = Notification.Name(rawValue: "eosLoginStatusChanged")
	
	public static let IAPPurchased = Notification.Name("IAP-Purchased")
	public static let IAPRefunded = Notification.Name("IAP-Refunded")
	public static let AdsStatusChanged = Notification.Name("AdsStatusChanged")
	
	public static let levelFinished = Notification.Name("levelFinished")
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
	
	public static func rgb(_ rgb: Int, alpha: CGFloat = 1.0) -> UIColor {
		return UIColor(
			red: CGFloat((Float((rgb & 0xff0000) >> 16)) / 255.0),
			green: CGFloat((Float((rgb & 0x00ff00) >> 8)) / 255.0),
			blue: CGFloat((Float((rgb & 0x0000ff) >> 0)) / 255.0),
			alpha: alpha)
	}
	
	public static var background = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
	public static var popupBackground = UIColor.rgb(0xf0f0f0)
	public static var buttonBackground = UIColor.rgb(0xe5e5e5)
	public static var buttonHighlightedBackground = UIColor.rgb(0xbababa)
	public static var buttonDisabledBackground = UIColor.rgb(0xbbbbbb)
	
	public static var sky = UIColor(red: 112/255, green: 196/255, blue: 254/255, alpha: 1)
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
	
	struct Key {
		static var cornerRadiusRatio = "cornerRadiusRatio"
	}
	
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
			return objc_getAssociatedObject(self, &Key.cornerRadiusRatio) as? CGFloat ?? 0
		}
		set {
			objc_setAssociatedObject(self, &Key.cornerRadiusRatio, newValue, .OBJC_ASSOCIATION_RETAIN)
			// Make sure that it's between 0.0 and 1.0. If not, restrict it to that range.
			let normalizedRatio = max(0.0, min(1.0, newValue))
			layer.cornerRadius = min(frame.width, frame.height) * normalizedRatio
		}
	}
	
	public var viewController: UIViewController? {
		var parentResponder: UIResponder? = self.next
		while parentResponder != nil {
			if let viewController = parentResponder as? UIViewController {
				return viewController
			}
			parentResponder = parentResponder?.next
		}
		return nil
	}
	
	public func asImage() -> UIImage {
		if #available(iOS 10.0, *) {
			let renderer = UIGraphicsImageRenderer(bounds: bounds)
			return renderer.image { rendererContext in
				layer.render(in: rendererContext.cgContext)
			}
		} else {
			UIGraphicsBeginImageContext(self.frame.size)
			self.layer.render(in:UIGraphicsGetCurrentContext()!)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return UIImage(cgImage: image!.cgImage!)
		}
	}
	
	public func asPngData() -> Data {
		let renderer = UIGraphicsImageRenderer(bounds: bounds)
		return renderer.pngData { rendererContext in
			layer.render(in: rendererContext.cgContext)
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
	
	public func loadSpinner() {
		fromGif(resourceName: "spinner-icon-gif", ofType: "jpg")
	}
	
	public func downloadImage(from url: URL, completion: @escaping (_ ok: Bool) -> Void) {
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
	/// receive keyboard presses from ViewController
	@objc open func pressesDidBegin(_ presses: Set<UIPress>, with event: UIPressesEvent?) {}
}

extension GKError {
	
	public var content: String {
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

@available(iOS 10.3, *)
extension SKStoreReviewController {
	public static func requestReviewInCurrentScene(_ tag: String) {
		if #available(iOS 14.0, *), let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
			requestReview(in: scene)
		} else {
			requestReview()
		}
	}
}
