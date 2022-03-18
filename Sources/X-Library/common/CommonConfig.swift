//
//  Created by Thang Nguyen on 6/27/21.
//

import Foundation
import CoreGraphics

public struct CommonConfig {
	
	public static let gcmMessageIDKey: String = "gcm.message_id"
	public static let scoresKey = "scores"
	
	public static let fontName = "Chalkboard SE"
	public static let fontSize: CGFloat = 17
	
	public static let dateFormat = "yyyy-MM-dd HH:mm:ss"
	public static let dateFormatter: DateFormatter = {
		let dft = DateFormatter()
		dft.dateFormat = dateFormat
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
		public static let appInstallVersion = "app-install-version"
		// public static let isFirstRun = "is_first_run"
		public static let appDataVersion = "app-data-version"
		// public static let welcomeVersion = "welcome-version"
		public static let newAppUpdateNotiVersion = "new-app-update-noti-version"
		
		public static let appOpenCount = "app_open_count"
		public static let sessionsCount = "sessions_count"
		public static let gamesCount = "games_count"
		public static let gameLevel = "gameLevel"
		public static let bestScore = "best_score"
		
		public static let gameCenterPlayerInfo = "game-center-player-info"
		
		public static let purchased = "purchased"
		public static let coinCount = "coin-count"
		public static let lastDailyRewardingTime = "last_daily_rewarding_time"
		
		// configs from server
		public static let hideAdsWhilePlaying = "hide-ads-while-playing"
	}
}

public enum ERROR: Int {
	case unknown
	case InvalidHardware
	case BannedDevice
	case UpdateRequired
	case UpdateRecommended
	case NoReceiptFound
}
