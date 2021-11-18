//
//  Created by Thang Nguyen on 10/18/21.
//

import SpriteKit

public class Popup: SKSpriteNode {
	
	private let TAG = "🪟"
	
	var contentNode: SKSpriteNode!
	var nativeContentSize: CGSize!
	
	init(fileName: String, zPosition: CGFloat = SceneLayer.popup.rawValue) {
		let overlayScene = SKScene(fileNamed: fileName)!
		let contentTemplateNode = overlayScene.childNode(withName: "Overlay") as! SKSpriteNode
		
		// Create a background node with the same color as the template.
		super.init(texture: nil, color: contentTemplateNode.color, size: contentTemplateNode.size)
		self.zPosition = zPosition
		
		// Copy the template node into the background node.
		self.contentNode = contentTemplateNode.copy() as? SKSpriteNode
		self.contentNode.position = .zero
		self.addChild(contentNode)
		
		// Set the content node to a clear color to allow the background node to be seen through it.
		self.contentNode.color = .clear
		
		// Store the current size of the content to allow it to be scaled correctly.
		self.nativeContentSize = contentNode.size
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateScale() {
		guard let viewSize = scene?.view?.frame.size else {
			return
		}
		
		// Resize the background node.
		size = viewSize
		
		// Scale the content so that the height always fits.
		let scale = viewSize.height / nativeContentSize.height
		contentNode.setScale(scale)
	}
}
