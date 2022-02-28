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
	
	public func removeTimeStamp(_ tag: String) -> Date {
		guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
			fatalError("!-  [\(tag)] Failed to strip time from Date object: \(self)")
		}
		return date
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
	
	public static let coinChanged = Notification.Name("coinChanged")
	
	public static let homeEntered = Notification.Name("homeEntered")
	public static let gameEntered = Notification.Name("gameEntered")
	public static let gameFinished = Notification.Name("gameFinished")
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
	
	public static var blue1 = UIColor.rgb(0x63ACE5)
	public static var blue2 = UIColor.rgb(0x1492FF)
	public static var blue3 = UIColor.rgb(0x2ab7ca)
	public static var blue4 = UIColor.rgb(0x6497b1)
	public static var blackTransparent = UIColor.rgb(0x000000, alpha: 0.5)
	public static var blackTransparent70 = UIColor.rgb(0x000000, alpha: 0.7)
	
	public static var sky = UIColor(red: 112/255, green: 196/255, blue: 254/255, alpha: 1)
	public static var veanee1 = UIColor.rgb(0x63c5da)
	
	public static var link = UIColor.rgb(0x007AFF)
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
	
	private struct Key {
		static var cornerRadiusRatio = "cornerRadiusRatio"
		static var shadowColor = "shadowColor"
		static var shadowRadius = "shadowRadius"
		static var glowView = "glowView"
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
			updateCorner("set")
		}
	}
	
	@IBInspectable public var shadowRadius: CGFloat {
		get {
			return objc_getAssociatedObject(self, &Key.shadowRadius) as? CGFloat ?? 0
		}
		set {
			objc_setAssociatedObject(self, &Key.shadowRadius, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	@IBInspectable public var shadowColor: UIColor? {
		get {
			return objc_getAssociatedObject(self, &Key.shadowColor) as? UIColor
		}
		set {
			objc_setAssociatedObject(self, &Key.shadowColor, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	var glowView: UIView? {
		get {
			return objc_getAssociatedObject(self, &Key.glowView) as? UIView
		}
		set(newGlowView) {
			objc_setAssociatedObject(self, &Key.glowView, newGlowView!, .OBJC_ASSOCIATION_RETAIN)
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
			// EXC_BAD_ACCESS (code=2, address=0x1234567891) when set layer.[some-property]
			layer.render(in: rendererContext.cgContext)
		}
	}
	
	public func updateCorner(_ tag: String) {
		// Make sure that it's between 0.0 and 1.0. If not, restrict it to that range.
		let normalizedRatio = max(0.0, min(1.0, cornerRadiusRatio))
		layer.cornerRadius = min(frame.width, frame.height) * normalizedRatio
	}
	
	public func dropShadow(_ tag: String) {
		dropShadow(tag, color: shadowColor, opacity: 0.7, offset: .zero, radius: shadowRadius)
	}
	
	public func dropShadow(_ tag: String, color: UIColor?, opacity: Float?, offset: CGSize?, radius: CGFloat?) {
		//let shadowLayer: CALayer
		//if let s = layer.sublayers?.first(where: { $0.name == "shadow" }) {
		//	shadowLayer = s
		//} else {
		//	shadowLayer = CALayer()
		//	shadowLayer.name = "shadow"
		//	// shadowLayer.shouldRasterize = true
		//	// shadowLayer.rasterizationScale = UIScreen.main.scale
		//
		//	layer.insertSublayer(shadowLayer, at: 0)
		//}
		
		layer.masksToBounds = false
		
		// if use shadowPath -> reset each time in layoutSubviews
		// layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
		layer.shadowColor = color?.cgColor
		if opacity != nil { layer.shadowOpacity = opacity! }
		if offset != nil { layer.shadowOffset = offset! }
		if radius != nil { layer.shadowRadius = radius! }
		
		// layer.shouldRasterize = true
		// layer.rasterizationScale = UIScreen.main.scale
	}
	
	public func startGlowingWithColor(color: UIColor, intensity: CGFloat) {
		self.startGlowingWithColor(color: color, fromIntensity: 0.1, toIntensity: intensity, repeat: true)
	}
	
	public func startGlowingWithColor(color: UIColor, fromIntensity: CGFloat, toIntensity: CGFloat, repeat shouldRepeat: Bool) {
		// If we're already glowing, don't bother
		if self.glowView != nil {
			return
		}
		
		// The glow image is taken from the current view's appearance.
		// As a side effect, if the view's content, size or shape changes,
		// the glow won't update.
		var image: UIImage
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
		do {
			self.layer.render(in: UIGraphicsGetCurrentContext()!)
			
			let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
			
			color.setFill()
			
			path.fill(with: .sourceAtop, alpha: 1.0)
			
			image = UIGraphicsGetImageFromCurrentImageContext()!
		}
		
		UIGraphicsEndImageContext()
		
		// Make the glowing view itself, and position it at the same
		// point as ourself. Overlay it over ourself.
		let glowView = UIImageView(image: image)
		glowView.center = self.center
		self.superview!.insertSubview(glowView, aboveSubview:self)
		
		// We don't want to show the image, but rather a shadow created by
		// Core Animation. By setting the shadow to white and the shadow radius to
		// something large, we get a pleasing glow.
		glowView.alpha = 0
		glowView.layer.shadowColor = color.cgColor
		glowView.layer.shadowOffset = .zero
		glowView.layer.shadowRadius = 10
		glowView.layer.shadowOpacity = 1.0
		
		// Create an animation that slowly fades the glow view in and out forever.
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.fromValue = fromIntensity
		animation.toValue = toIntensity
		animation.repeatCount = shouldRepeat ? .infinity : 0 // HUGE_VAL = .infinity / Thanks http://stackoverflow.com/questions/7082578/cabasicanimation-unlimited-repeat-without-huge-valf
		animation.duration = 1.0
		animation.autoreverses = true
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		
		glowView.layer.add(animation, forKey: "pulse")
		
		// Finally, keep a reference to this around so it can be removed later
		self.glowView = glowView
	}
	
	public func glowOnceAtLocation(point: CGPoint, inView view: UIView) {
		self.startGlowingWithColor(color: .white, fromIntensity: 0, toIntensity: 0.6, repeat: false)
		
		self.glowView!.center = point
		view.addSubview(self.glowView!)
		
		let delay: Double = 2 * Double(Int64(NSEC_PER_SEC))
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
			self.stopGlowing()
		}
	}
	
	public func glowOnce() {
		self.startGlowing()
		
		let delay: Double = 2 * Double(Int64(NSEC_PER_SEC))
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
			self.stopGlowing()
		}
		
	}
	
	// Create a pulsing, glowing view based on this one.
	public func startGlowing() {
		self.startGlowingWithColor(color: UIColor.white, intensity: 0.6);
	}
	
	// Stop glowing by removing the glowing view from the superview
	// and removing the association between it and this object.
	public func stopGlowing() {
		self.glowView!.removeFromSuperview()
		self.glowView = nil
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
	
	public func resized(to size: CGSize) -> UIImage {
		return UIGraphicsImageRenderer(size: size).image { _ in
			draw(in: CGRect(origin: .zero, size: size))
		}
	}
}

extension SKScene {
	@objc open func willMove(_ tag: String, to view: SKView) {}
	
	/// receive keyboard presses from ViewController
	@objc open func pressesDidBegin(_ tag: String, _ presses: Set<UIPress>, with event: UIPressesEvent?) {}
}

extension GKScene {
	public convenience init(skScene: SKScene.Type) {
		self.init()
		
		self.rootNode = skScene.init()
	}
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
