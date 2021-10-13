//
//  Created by Thang Nguyen on 6/27/21.
//

import GoogleMobileAds

struct CommonConfig {
	
	static let gcmMessageIDKey: String = "gcm.message_id"
	static let scoresKey = "scores"
	static let font = UIFont(name: "Chalkboard SE", size: 19)
	
	static let dateFormatter: DateFormatter = {
		let dft = DateFormatter()
		dft.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dft
	}()
	
	struct Settings {
		static var sound: String = "sound_enabled_preference"
		static var sound_volume: String = "sound_volume_preference"
		static var music: String = "music_enabled_preference"
		static var music_volume: String = "music_volume_preference"
		static var vibration: String = "vibration_enabled_preference"
	}
}
