//
//  Created by Thang Nguyen on 6/27/21.
//

import GoogleMobileAds

public struct CommonConfig {
	
	public static let gcmMessageIDKey: String = "gcm.message_id"
	public static let scoresKey = "scores"
	public static let font = UIFont(name: "Chalkboard SE", size: 19)
	
	public static let dateFormatter: DateFormatter = {
		let dft = DateFormatter()
		dft.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dft
	}()
	
	public struct Settings {
		public static let sound: String = "sound_enabled_preference"
		public static let sound_volume: String = "sound_volume_preference"
		public static let music: String = "music_enabled_preference"
		public static let music_volume: String = "music_volume_preference"
		public static let vibration: String = "vibration_enabled_preference"
	}
	
	public struct Keys {
		public static let purchased = "purchased"
	}
}
