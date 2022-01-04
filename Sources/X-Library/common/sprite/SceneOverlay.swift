//
//  Created by Thang Nguyen on 10/18/21.
//

import SpriteKit

open class SceneOverlay: SKSpriteNode {
	
	private static let TAG = "🪟"
	private let TAG = "🪟"
	
	public var nativeContentSize: CGSize!
	
	
	public static func initiate(fileName: String, zPosition: CGFloat = SceneLayer.popup.rawValue) -> SceneOverlay {
		print("-------  \(TAG) [\(fileName)]")
		
		let overlayScene = SKScene(fileNamed: fileName)!
		let contentTemplateNode = overlayScene.childNode(withName: "Overlay") as! SceneOverlay
		
		let overlay = contentTemplateNode.copy() as! SceneOverlay
		
		// Store the current size of the content to allow it to be scaled correctly.
		overlay.nativeContentSize = contentTemplateNode.size
		
		overlay.zPosition = zPosition
		overlay.position = .zero
		
		overlay.sceneDidLoad("init(\(fileName))")
		
		return overlay
	}
	
	open func sceneDidLoad(_ tag: String) {
		print("--  \(TAG) | sceneDidLoad [\(tag)]: \(isPaused)")
	}
	
	open func willMove(_ tag: String, to scene: SKScene) {
		print("--  \(TAG) | willMove to scene [\(tag)]")
		
		size = scene.frame.size
	}
	
	open func didMove(_ tag: String, to scene: SKScene) {
		print("--  \(TAG) | didMove to scene [\(tag)]")
		
		isPaused = false
	}
	
	open func willMove(_ tag: String, from scene: SKScene) {
		print("--  \(TAG) | willMove from scene [\(tag)]")
	}
	
	private func superRemoveFromParent() {
		super.removeFromParent()
	}
	
	open override func removeFromParent() {
		removeFromParent("x", completion: nil)
	}
	
	open func removeFromParent(_ tag: String, completion: (() -> Void)? = nil) {
		let a = action(forKey: "remove")
		if parent == nil || a != nil {
			print("--  \(TAG) | removeFromParent [\(tag)]: already removed: \(parent == nil) | \(a != nil)")
			return
		}
		
		run(SKAction.sequence([
			SKAction.fadeOut(withDuration: 0.25),
			SKAction.run { [weak self] in
				self!.willMove("removeFromParent|\(tag)", from: self!.scene!)
				self!.superRemoveFromParent()
				completion?()
			},
		]), withKey: "remove")
	}
}
