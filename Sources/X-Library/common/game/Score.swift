//
//  Created by Thang Nguyen on 7/26/21.
//

import UIKit
import GameKit

public class Score: CustomStringConvertible {
	var id: Int?
	public var score: Int
	public var time: Date
	
	var player: Player
	
	public var gkScore: GKScore?
	
	public var tap: Int?
	
	public var description: String { return "( \(id as Any) | \(time) | \(score) | \(player) )"}
	
	public init(_ score: Int) {
		self.score = score
		self.time = Date()
		self.player = Player(GKLocalPlayer.local)
	}
	
	public init(_ gkScore: GKScore) {
		self.gkScore = gkScore
		self.score = Int(gkScore.value)
		self.time = gkScore.date
		self.player = Player(gkScore.player)
	}
}
