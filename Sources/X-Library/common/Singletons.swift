//
//  Created by Thang Nguyen on 7/29/21.
//

import UIKit
import AVFoundation
import StoreKit

public class Singletons {
	
	private static let TAG = "SgT"
	private let TAG = "SgT"
	
	public static let instance = Singletons()
	
	private var musicOn = false
	
	private var sounds: [AVAudioPlayer] = []
	
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
	
	public let paymentSuccessSound: AVAudioPlayer = {
		let url = Bundle.module.url(forResource: "payment_success", withExtension: "wav")!
		let s = try! AVAudioPlayer(contentsOf: url)
		s.volume = Helper.soundVolume
		return s
	}()
	
	
	private init() {
		NSLog("-------  \(TAG)")
		
		_ = backgroundAudio
		
		if btnSound != nil { sounds.append(btnSound!) }
		if whooshSound != nil { sounds.append(whooshSound!) }
		if whooshSound2 != nil { sounds.append(whooshSound2!) }
		sounds.append(paymentSuccessSound)
		
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
		NSLog("--  \(TAG) | toggleSound: \(notification.object as? Any ?? "--")")
	}
	
	@objc func changeSoundVolume(_ notification: NSNotification) {
		sounds.forEach { $0.volume = Float(notification.object as! CGFloat) }
	}
	
	@objc func toggleMusic(_ notification: NSNotification) {
		NSLog("--  \(TAG) | toggleMusic: \(notification.object as? Any ?? "--")")
		
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
