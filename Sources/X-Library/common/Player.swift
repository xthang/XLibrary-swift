//
//  Created by Thang Nguyen on 9/10/21.
//

import GameKit

class Player: CustomStringConvertible {
	var id: Int?
	var playerID: String?
	var name: String?
	
	var gkPlayer: GKPlayer
	
	var description: String { return "Player ( \(id as Any) | \(playerID as Any) | \(name as Any) | \(gkPlayer) )"}
	
	init() {
		self.gkPlayer = GKLocalPlayer.local
	}
	
	init(_ gkPlayer: GKPlayer) {
		self.gkPlayer = gkPlayer
	}
}
