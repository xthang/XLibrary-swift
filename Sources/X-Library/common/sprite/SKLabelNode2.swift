//
//  Created by Thang Nguyen on 1/2/22.
//

import SpriteKit

public class SKLabelNode2: SKNode {
	
	private let TAG = "\(SKLabelNode2.self)"
	
	public var verticalAlignmentMode: SKLabelVerticalAlignmentMode = .baseline
	public var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode = .center
	
	public var numberOfLines: Int = 0
	
	public var lineBreakMode: NSLineBreakMode = .byTruncatingTail
	
	public var preferredMaxLayoutWidth: CGFloat = 0
	
	public var fontTextureAtlas: SKTextureAtlas! {
		didSet {
			fontTextureAtlas.textureNames.forEach {
				fontTextureAtlas.textureNamed($0).filteringMode = .nearest
			}
		}
	}
	public var fontMap: ((SKTextureAtlas, Character) -> SKTexture)!
	public var text: String? {
		didSet {
			update("text")
		}
	}
	public var fontSize: CGFloat = 0 {
		didSet {
			update("fontSize")
		}
	}
	public var textSpace: CGFloat = 0 {
		didSet {
			update("space")
		}
	}
	
	private var textNodes: SKNode = .init()
	
	
	init(fontTextureAtlas: SKTextureAtlas, fontMap: @escaping (SKTextureAtlas, Character) -> SKTexture, text: String? = nil) {
		print("-------  \(TAG) | \(String(describing: fontMap)) | \(text ?? "--")")
		
		self.fontTextureAtlas = fontTextureAtlas
		self.fontMap = fontMap
		self.text = text
		
		super.init()
		
		self.addChild(textNodes)
	}
	
	public override init() {
		// print("-------  \(TAG)")
		super.init()
		
		self.addChild(textNodes)
	}
	
	required init?(coder aDecoder: NSCoder) {
		// print("-------  \(TAG) | (coder:)")
		super.init(coder: aDecoder)
		
		self.addChild(textNodes)
	}
	
	open override func copy(with zone: NSZone? = nil) -> Any {
		// print("--  \(TAG) | copy: \(zone as Any? ?? "--")")
		
		let n = super.copy(with: zone) as! SKLabelNode2
		// n.textNodes = self.textNodes.copy() as! SKNode
		
		return n
	}
	
	private func update(_ tag: String) {
		// print("--  \(TAG) update [\(tag)]: \(text ?? "--") | \(fontSize) | \(textSpace)")
		
		textNodes.removeAllChildren()
		
		if fontSize == 0 { return }
		
		var width: CGFloat = 0
		var isFirst = true
		text?.forEach {
			let texture = fontMap(fontTextureAtlas, $0)
			let textNode = SKSpriteNode(texture: texture)
			textNode.size = .init(width: fontSize * texture.size().width / texture.size().height, height: fontSize)
			textNode.position.x = width + (isFirst ? 0 : textSpace) + textNode.size.width / 2
			textNodes.addChild(textNode)
			
			width = width + (isFirst ? 0 : textSpace) + textNode.size.width
			if isFirst {
				isFirst = false
			}
		}
		
		switch horizontalAlignmentMode {
			case .center: textNodes.position.x = -width / 2
			case .right: textNodes.position.x = -width
			default: break
		}
	}
}
