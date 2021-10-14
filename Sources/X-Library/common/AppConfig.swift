//
//  Created by Thang Nguyen on 6/27/21.
//

import GoogleMobileAds

public struct AppConfig {
	
	private static let TAG = "🎛"
	
	static let nsDictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "AppConfig", ofType: "plist")!)!
	
	public static let appID = nsDictionary["AppID"] as! Int
	public static let appleID: String = nsDictionary["AppleID"] as! String
	public static let shareURL: String = nsDictionary["ShareURL"] as! String
	
	static let keychainAccessGroup: String = nsDictionary["KeychainAccessGroup"] as! String
	static let keychainIdService: String = nsDictionary["KeychainIdService"] as! String
	static let keychainDeviceIdKey: String = nsDictionary["KeychainDeviceIdKey"] as! String
	static let keychainXUserIdKey: String = nsDictionary["KeychainXUserIdKey"] as! String
	
	static var gAdTestDevices: [ String ] = (nsDictionary["GADTestDevices"] as! Array<Dictionary<String, String>>).map({ item in
		item["id"]!
	})
	
	static let unityAppID: String = nsDictionary["UnityAppID"] as! String
	static let unityGameID: String = nsDictionary["UnityGameID"] as! String
	static let unityAdEnabled: Bool = nsDictionary["UnityAdEnabled"] as! Bool
	
	public static func initiate() {
		NSLog("-------  \(TAG)")
		
		gAdTestDevices.append(GADSimulatorID)
	}
	
	struct GADUnit {
		static let dict1 = nsDictionary["GADUnits"] as! NSDictionary
		
		static var main: String = dict1["Main"] as! String
	}
	
	struct UnityAdUnit {
		static let dict1 = nsDictionary["UnityAdUnits"] as! NSDictionary
		
		static var main: String = dict1["Main"] as! String
	}
	
	struct GameCenter {
		static let dict1 = nsDictionary["GameCenter"] as! NSDictionary
		
		struct LeaderBoard {
			static let dict2 = dict1["Leaderboards"] as! NSDictionary
			
			static var all: String = dict2["AllScores"] as! String
		}
		
		struct Achievement {
			static let dict2 = dict1["Achievements"] as! NSDictionary
			
			static var score100: String = dict2["Score100"] as! String
		}
	}
}
