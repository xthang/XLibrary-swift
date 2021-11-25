//
//  Created by Thang Nguyen on 6/27/21.
//

import GoogleMobileAds

public struct AppConfig {
	
	private static let TAG = "🎛"
	
	public static let nsDictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "AppConfig", ofType: "plist")!)!
	
	public static let appID = nsDictionary["AppID"] as! Int
	public static let appleID: String = nsDictionary["AppleID"] as! String
	public static let aboutURL: String = nsDictionary["AboutURL"] as! String
	public static let shareURL: String = nsDictionary["ShareURL"] as! String
	
	static let keychainAccessGroup: String = nsDictionary["KeychainAccessGroup"] as! String
	static let keychainIdService: String = nsDictionary["KeychainIdService"] as! String
	public static let keychainDeviceIdKey: String = nsDictionary["KeychainDeviceIdKey"] as! String
	public static let keychainXUserIdKey: String = nsDictionary["KeychainXUserIdKey"] as! String
	
	static var gAdTestDevices: [ String ] = (nsDictionary["GADTestDevices"] as! Array<Dictionary<String, String>>).map({ item in
		item["id"]!
	})
	
	static let unityAppID: String = nsDictionary["UnityAppID"] as! String
	static let unityGameID: String = nsDictionary["UnityGameID"] as! String
	static let unityAdEnabled: Bool = nsDictionary["UnityAdEnabled"] as! Bool
	
	public static func initiate(_ tag: String) {
		NSLog("-------  \(TAG) | \(tag)")
		
		_ = appID
		_ = appleID
		_ = aboutURL
		_ = shareURL
		
		_ = keychainAccessGroup
		_ = keychainIdService
		_ = keychainDeviceIdKey
		_ = keychainXUserIdKey
		
		_ = GameCenter.LeaderBoard.all
		
		_ = GADUnit.banner
		_ = GADUnit.interstitial
		gAdTestDevices.append(GADSimulatorID)
		
		_ = unityAppID
		_ = unityGameID
		_ = unityAdEnabled
		_ = UnityAdUnit.banner
		_ = UnityAdUnit.interstitial
	}
	
	public struct GameCenter {
		public static let dict1 = nsDictionary["GameCenter"] as! NSDictionary
		
		struct LeaderBoard {
			static let dict2 = dict1["Leaderboards"] as! NSDictionary
			
			static var all: String = dict2["All"] as! String
		}
		
		public struct Achievement {
			public static let dict2 = dict1["Achievements"] as! NSDictionary
		}
	}
	
	struct GADUnit {
		static let dict1 = nsDictionary["GADUnits"] as! NSDictionary
		
		static var banner: String = dict1["Banner"] as! String
		static var interstitial: String = dict1["Interstitial"] as! String
	}
	
	struct UnityAdUnit {
		static let dict1 = nsDictionary["UnityAdUnits"] as! NSDictionary
		
		static var banner: String = dict1["Banner"] as! String
		static var interstitial: String = dict1["Interstitial"] as! String
	}
}
