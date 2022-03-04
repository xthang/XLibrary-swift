//
//  GameViewController.swift
//  Shoot
//
//  Created by Thang Nguyen on 03/04/22.
//

import UIKit
import SpriteKit
import GameplayKit

open class BaseGameViewController: BaseViewController {
	
	private static let TAG = "~🎮"
	private let TAG = "~🎮"
	
	@IBOutlet public weak var skView: SKView!
	
	public var homeScene: BaseSKScene!
	
	open override var prefersStatusBarHidden: Bool {
		return true
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		//
		skView.ignoresSiblingOrder = true
		
#if DEBUG
		//skView.showsFPS = true
		//skView.showsDrawCount = true
		//skView.showsNodeCount = true
		//skView.showsQuadCount = true
		//skView.showsPhysics = true
		//skView.showsFields = true
		//if #available(iOS 13.0, *) {
		//	skView.showsLargeContentViewer = true
		//}
#endif
	}
	
	open override func loadHomeView(_ tag: String) {
		super.loadHomeView(tag)
		
		// Present the scene
		skView.presentScene("\(TAG)|loadHomeView|\(tag)", homeScene)
	}
	
	open override func deactivate(_ noti: NSNotification) {
		// NSLog("--  \(TAG) | deactivate: \(hash)")
		
		skView.isPaused = true
		(skView.scene as? BaseSKScene)?.deactivate("\(TAG)|deactivate", noti)
	}
	
	open override func activate(_ noti: NSNotification) {
		// NSLog("--  \(TAG) | activate: \(hash)")
		
		skView.isPaused = false
		(skView.scene as? BaseSKScene)?.activate("\(TAG)|activate", noti)
	}
	
	// detect keyboard pressed
	open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		super.pressesBegan(presses, with: event)
		
		skView.scene?.pressesDidBegin(TAG, presses, with: event)
	}
}
