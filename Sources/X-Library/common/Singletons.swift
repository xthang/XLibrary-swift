//
//  Created by Thang Nguyen on 7/29/21.
//

import UIKit
import AVFoundation

public class Singletons {
	private let TAG = "SgT"
	
	public static var instance = Singletons()
	
	private var musicOn = false
	
	private let backgroundAudio : AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "background", withExtension: "mp3") {
			// NSLog("--  \(TAG) | init background audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.numberOfLoops = -1
			s?.volume = Helper.musicVolume
		}
		return s
	}()
	
	public let btnSound: AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "button", withExtension: "wav") {
			// NSLog("--  \(TAG) | init button audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.volume = Helper.soundVolume
		}
		return s
	}()
	
	public let whooshSound: AVAudioPlayer? = {
		var s: AVAudioPlayer? = nil
		if let url = Bundle.main.url(forResource: "whoosh", withExtension: "wav") {
			// NSLog("--  \(TAG) | init button audio ...: \(url)")
			s = try? AVAudioPlayer(contentsOf: url)
			s?.volume = Helper.soundVolume
		}
		return s
	}()
	
	public let whooshSound2: AVAudioPlayer? = {
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
		
		let _ = backgroundAudio
		let _ = btnSound
		let _ = whooshSound
		let _ = whooshSound2
		
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
		if let bgAudio = backgroundAudio {
			if musicOn && Helper.musicOn && !bgAudio.isPlaying { bgAudio.play() }
			else if !Helper.musicOn && bgAudio.isPlaying { bgAudio.stop() }
		}
	}
	
	@objc func toggleSound(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleSound")
	}
	
	@objc func changeSoundVolume(_ notification: NSNotification) {
		btnSound?.volume = Float(notification.object as! CGFloat)
		whooshSound?.volume = Float(notification.object as! CGFloat)
		whooshSound2?.volume = Float(notification.object as! CGFloat)
	}
	
	@objc func toggleMusic(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleMusic")
		
		if notification.object as! Bool {
			playMusic()
		} else {
			pauseMusic()
		}
	}
	
	@objc func changeMusicVolume(_ notification: NSNotification) {
		backgroundAudio?.volume = Float(notification.object as! CGFloat)
	}
	
	public func playMusic() {
		musicOn = true
		if Helper.musicOn, let bgAudio = backgroundAudio, !bgAudio.isPlaying {
			bgAudio.play()
		}
	}
	
	public func pauseMusic() {
		musicOn = false
		if let bgAudio = backgroundAudio, bgAudio.isPlaying {
			bgAudio.stop()
		}
	}
}
