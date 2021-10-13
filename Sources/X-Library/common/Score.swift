//
//  Created by Thang Nguyen on 7/26/21.
//

import UIKit
import GameKit

class Score: CustomStringConvertible {
	var id: Int?
	var score: Int
	var time: Date
	
	var player: Player
	
	var gkScore: GKScore?
	
	var tap: Int?
	
	var description: String { return "( \(id as Any) | \(time) | \(score) | \(player) )"}
	
	init(_ score: Int) {
		self.score = score
		self.time = Date()
		self.player = Player(GKLocalPlayer.local)
	}
	
	init(_ gkScore: GKScore) {
		self.gkScore = gkScore
		self.score = Int(gkScore.value)
		self.time = gkScore.date
		self.player = Player(gkScore.player)
	}
}
