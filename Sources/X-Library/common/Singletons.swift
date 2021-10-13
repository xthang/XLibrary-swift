//
//  Created by Thang Nguyen on 7/29/21.
//

import UIKit
import AVFoundation

class Singletons {
	private let TAG = "SgT"
	
	static var instance = Singletons()
	
	static let backgroundAudio : AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "background", withExtension: "mp3") {
			// NSLog("--  \(TAG) | init background audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.numberOfLoops = -1
			s?.volume = Helper.musicVolume
		}
		return s
	}()
	
	static let btnSound: AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "pop", withExtension: "wav") {
			// NSLog("--  \(TAG) | init button audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.volume = Helper.soundVolume
		}
		return s
	}()
	
	static let whooshSound: AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "whoosh", withExtension: "wav") {
			// NSLog("--  \(TAG) | init button audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.volume = Helper.soundVolume
		}
		return s
	}()
	
	static let whooshSound2: AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "whoosh", withExtension: "m4a") {
			// NSLog("--  \(TAG) | init button audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.volume = Helper.soundVolume
		}
		return s
	}()
	
	
	private init() {
		NSLog("-------  \(TAG)")
		
		let _ = Singletons.backgroundAudio
		let _ = Singletons.btnSound
		let _ = Singletons.whooshSound
		let _ = Singletons.whooshSound2
		
		if #available(iOS 13.0, *) {
			NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
		} else {
			NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(toggleSound), name: .sound, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeSoundVolume), name: .soundVolume, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(toggleMusic), name: .music, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeMusicVolume), name: .musicVolume, object: nil)
	}
	
	@objc func enterForeground(_ notification: NSNotification) {
		if let bgAudio = Singletons.backgroundAudio {
			if Helper.musicOn && !bgAudio.isPlaying { bgAudio.play() }
			else if !Helper.musicOn && bgAudio.isPlaying { bgAudio.stop() }
		}
	}
	
	@objc func toggleSound(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleSound")
	}
	
	@objc func changeSoundVolume(_ notification: NSNotification) {
		Singletons.btnSound?.volume = Float(notification.object as! CGFloat)
		Singletons.whooshSound?.volume = Float(notification.object as! CGFloat)
		Singletons.whooshSound2?.volume = Float(notification.object as! CGFloat)
	}
	
	@objc func toggleMusic(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleMusic")
		if notification.object as! Bool {
			Singletons.backgroundAudio!.play()
		} else {
			Singletons.backgroundAudio!.pause()
		}
	}
	
	@objc func changeMusicVolume(_ notification: NSNotification) {
		Singletons.backgroundAudio?.volume = Float(notification.object as! CGFloat)
	}
}
