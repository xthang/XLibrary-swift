//
//  Created by Thang Nguyen on 12/7/21.
//

import UIKit

@objc public class Theme: NSObject {
	
	public static var current: Theme!
	
	static var light = Theme(filename: "light")
	static var dark = Theme(filename: "dark")
	static var cartoon = Theme(filename: "cartoon")
	
	public var settings: ThemeSettings
	
	init(filename: String) {
		settings = ThemeSettings(filename: filename)
	}
}

public struct ThemeSettings {
	
	// Common
	
	public var fontName: String?
	public var fontSize: CGFloat?
	public var fontSizeByPercent: CGFloat?
	public var fontSizeLarge: CGFloat?
	public var fontSizeLarge1: CGFloat?
	
	public var textColor: UIColor?
	public var backgroundColor: UIColor?
	
	// Popup
	
	public var popupStyle: PopupAlert.Style?
	public var popupBackgroundColor: UIColor?
	public var popupCornerRadiusRatio: CGFloat?
	public var popupShadowRadius: CGFloat?
	public var popupShadowColor: UIColor?
	
	// Button
	
	public var buttonLayout: PopupAlert.ButtonLayout?
	public var buttonHeight: CGFloat?
	public var buttonFontSize: CGFloat?
	
	public var buttonBackgroundColor: UIColor?
	public var buttonBackgroundImage: UIImage?
	public var buttonTextColor: UIColor?
	
	public var buttonPrimary1BackgroundColor: UIColor?
	public var buttonPrimary1BackgroundImage: UIImage?
	public var buttonPrimary1TextColor: UIColor?
	
	public var buttonHighlightedBackgroundColor: UIColor?
	public var buttonHighlightedBackgroundImage: UIImage?
	public var buttonHighlightedTextColor: UIColor?
	
	public var buttonDisabledBackgroundColor: UIColor?
	public var buttonDisabledBackgroundImage: UIImage?
	public var buttonDisabledTextColor: UIColor?
	
	public var buttonCornerRadiusRatio: CGFloat?
	
	public var buttonShadowRadius: CGFloat?
	public var buttonShadowColor: UIColor?
	
	// Snackbar
	
	public var snackbarFont: UIFont?
	
	init(filename: String) {
		NSLog("-------  \(Theme.self) | \(filename)")
		
		let path = Bundle.main.path(forResource: "theme-" + filename, ofType: "plist")!
		let plist = FileManager.default.contents(atPath: path)! //or Data(contentsOf: url)
		let themeItems = try! PropertyListSerialization.propertyList(from: plist, format: nil) as! [String: AnyObject]
		
		fontName = themeItems["fontName"] as? String
		fontSize = themeItems["fontSize"] as? CGFloat
		if let i = themeItems["fontSizePercent"] as? CGFloat {
			fontSizeByPercent = UIScreen.screens.first!.bounds.height * i
		}
		fontSizeLarge = themeItems["fontSizeLarge"] as? CGFloat
		fontSizeLarge1 = themeItems["fontSizeLarge1"] as? CGFloat
		if let i = themeItems["textColor"], i as? String != "" {
			textColor = try! ThemeSettings.getColor(i)
		}
		if let i = themeItems["backgroundColor"], i as? String != "" {
			backgroundColor = try! ThemeSettings.getColor(i)
		}
		
		if let i = themeItems["popupStyle"] as? String {
			popupStyle = PopupAlert.Style(rawValue: i)
		}
		if let i = themeItems["popupBackgroundColor"], i as? String != "" {
			popupBackgroundColor = try! ThemeSettings.getColor(themeItems["popupBackgroundColor"]!)
		}
		popupCornerRadiusRatio = themeItems["popupCornerRadiusRatio"] as? CGFloat
		popupShadowRadius = themeItems["popupShadowRadius"] as? CGFloat
		if let i = themeItems["popupShadowColor"], i as? String != "" {
			popupShadowColor = try! ThemeSettings.getColor(i)
		}
		
		if let i = themeItems["buttonLayout"] as? String {
			buttonLayout = PopupAlert.ButtonLayout(rawValue: i)
		}
		buttonHeight = themeItems["buttonHeight"] as? CGFloat
		buttonFontSize = themeItems["buttonFontSize"] as? CGFloat
		
		if let i = themeItems["buttonBackgroundColor"], i as? String != "" {
			buttonBackgroundColor = try! ThemeSettings.getColor(i)
		}
		if let i = themeItems["buttonBackgroundImage"] as? String {
			buttonBackgroundImage = UIImage(named: i)
		}
		if let i = themeItems["buttonTextColor"], i as? String != "" {
			buttonTextColor = try! ThemeSettings.getColor(i)
		}
		
		if let i = themeItems["buttonPrimary1BackgroundColor"], i as? String != "" {
			buttonPrimary1BackgroundColor = try! ThemeSettings.getColor(i)
		}
		if let i = themeItems["buttonPrimary1BackgroundImage"] as? String {
			buttonPrimary1BackgroundImage = UIImage(named: i)
		}
		if let i = themeItems["buttonPrimary1TextColor"], i as? String != "" {
			buttonPrimary1TextColor = try! ThemeSettings.getColor(i)
		}
		
		if let i = themeItems["buttonHighlightedBackgroundColor"], i as? String != "" {
			buttonHighlightedBackgroundColor = try! ThemeSettings.getColor(i)
		}
		if let i = themeItems["buttonHighlightedBackgroundImage"] as? String {
			buttonHighlightedBackgroundImage = UIImage(named: i)
		}
		if let c = themeItems["buttonHighlightedTextColor"], c as? String != "" {
			buttonHighlightedTextColor = try! ThemeSettings.getColor(c)
		}
		
		if let i = themeItems["buttonDisabledBackgroundColor"], i as? String != "" {
			buttonDisabledBackgroundColor = try! ThemeSettings.getColor(i)
		}
		if let i = themeItems["buttonDisabledBackgroundImage"] as? String {
			buttonDisabledBackgroundImage = UIImage(named: i)
		}
		if let i = themeItems["buttonDisabledTextColor"], i as? String != "" {
			buttonDisabledTextColor = try! ThemeSettings.getColor(i)
		}
		
		if let f = themeItems["snackbarFont"] as? String, f != "", let fs = themeItems["snackbarFontSize"] as? CGFloat {
			snackbarFont = UIFont(name: f, size: fs)
		}
		
		buttonCornerRadiusRatio = themeItems["buttonCornerRadiusRatio"] as? CGFloat
		
		buttonShadowRadius = themeItems["buttonShadowRadius"] as? CGFloat
		if let i = themeItems["buttonShadowColor"], i as? String != "" {
			buttonShadowColor = try! ThemeSettings.getColor(i)
		}
		
		if let i = themeItems["buttonShadowColor"], i as? String != "" {
			buttonShadowColor = try! ThemeSettings.getColor(i)
		}
	}
	
	private static func getColor(_ item: Any) throws -> UIColor {
		if let item = item as? [String: CGFloat] {
			return .init(red: (item["red"] ?? 0) / 255, green: (item["green"] ?? 0) / 255, blue: (item["blue"] ?? 0) / 255, alpha: item["alpha"] ?? 0)
		} else if let item = item as? String, let colorHex = Int(item, radix: 16) {
			return .rgb(colorHex)
		} else if let colorName = item as? String {
			switch colorName {
				case "black": return .black
				case "white": return .white
				case "red": return .red
				case "blue": return .blue
				case "green": return .green
				case "yellow": return .yellow
				case "brown": return .brown
				case "darkGray": return .darkGray
				default: break
			}
		}
		
		throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "!-  can not parse color: \(item)"])
	}
}

@objc public protocol Themable {
	func applyTheme(_ tag: String, _ theme: Theme)
}
