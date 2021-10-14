//
//  Created by Thang Nguyen on 6/27/21.
//

import GameKit

public struct GameCenterHelper {
	static let TAG = "🕹"
	
	public static func authenticateLocalPlayer(_ fromView: UIViewController) {
		GKLocalPlayer.local.authenticateHandler = { viewController, error in
			var state : Bool = false
			
			if let vc = viewController {
				NSLog("--  \(TAG) | authen: 1: \(vc)")
				// fromView.present(vc, animated: true)
			} else if let err = error {
				NSLog("!-  \(TAG) | authen: Error: \(err.localizedDescription)")
			} else if GKLocalPlayer.local.isAuthenticated {
				NSLog("--  \(TAG) | authen: OK: \(GKLocalPlayer.local.isAuthenticated)")
				GKLocalPlayer.local.register(xGKLocalPlayerListener())
				if let bestLocal = ScoreData.getHishest() { submitScore(bestLocal.score) }
				state = true
			} else {
				NSLog("--  \(TAG) | authen: NotOK: \(GKLocalPlayer.local.isAuthenticated)")
			}
			
			NSLog("--  \(TAG) | player: \(GKLocalPlayer.local.playerID) | \(GKLocalPlayer.local)")
			NotificationCenter.default.post(name: .gcAuthenticationChanged, object: state)
		}
	}
	
	public static func showGameCenterLeaderBoard() {
		// NSLog("--  \(TAG) | showGameCenterLeaderBoard: \(GKLocalPlayer.local.isAuthenticated)")
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			
			let gcVC = GKGameCenterViewController()
			gcVC.gameCenterDelegate = xGKGameCenterControllerDelegate.instance
			gcVC.viewState = .default
			gcVC.leaderboardIdentifier = AppConfig.GameCenter.LeaderBoard.all
			topController.present(gcVC, animated: true)
		}
	}
	
	public static func submitScore(_ score: Int) {
		// Submit score to GC leaderboard
		let bestScoreInt = GKScore(leaderboardIdentifier: AppConfig.GameCenter.LeaderBoard.all, player: GKLocalPlayer.local)
		bestScoreInt.value = Int64(score)
		
		GKScore.report([bestScoreInt]) { error in
			if let err = error {
				NSLog("--> \(TAG) | updateScore error: \(err.localizedDescription)")
			} else {
				NSLog("--> \(TAG) | Best Score submitted to your Leaderboard!")
			}
		}
	}
	
	public static func loadScores(_ scope: GKLeaderboard.PlayerScope?, finished: @escaping (GKLeaderboard?, [GKScore]?, Error?)->()) {
		// NSLog("--  \(TAG) | loadScores: \(GKLocalPlayer.local.isAuthenticated)")
		
		GameCenterHelper.fetchLeaderboardBestScore { (leaderboard, e) in
			if e != nil {
				finished(leaderboard, nil, e)
			}
			
			if scope != nil { leaderboard?.playerScope = scope! }
			leaderboard?.loadScores { (scores, error) in
				// check for errors
				if error != nil {
					NSLog("!-- \(TAG) | loadScores -- \(error!)")
				}
				finished(leaderboard, scores, error)
			}
		}
	}
	
	static func fetchLeaderboards(finished: @escaping ([GKLeaderboard]?, Error?) -> ()) {
		// NSLog("--  \(TAG) | fetchLeaderboard: \(GKLocalPlayer.local.isAuthenticated)")
		
		GKLeaderboard.loadLeaderboards { (leaderboards, error) in
			if error != nil {
				NSLog("!-- \(TAG) | Fetching leaderboards: ERROR: \(error!)")
			}
			finished(leaderboards, error)
		}
	}
	
	static func fetchLeaderboardBestScore(finished: @escaping (GKLeaderboard?, Error?) -> ()) {
		// NSLog("--  \(TAG) | fetchLeaderboard: \(GKLocalPlayer.local.isAuthenticated)")
		
		GKLeaderboard.loadLeaderboards { (leaderboards, error) in
			if error != nil {
				NSLog("!-- \(TAG) | Fetching leaderboard: ERROR: \(error!)")
			}
			finished(leaderboards?[0], error)
		}
	}
	
	public static func presentMatchmaker(_ fromView: UIViewController) {
		// NSLog("--  \(TAG) | presentMatchmaker: \(GKLocalPlayer.local.isAuthenticated)")
		
		let request = GKMatchRequest()
		request.minPlayers = 2
		request.maxPlayers = 2
		request.inviteMessage = NSLocalizedString("Wanna play xGame?", comment: "")
		
		let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
		vc.turnBasedMatchmakerDelegate = xGKTurnBasedMatchmakerViewControllerDelegate.instance
		
		fromView.present(vc, animated: true)
	}
}

class xGKLocalPlayerListener: NSObject, GKLocalPlayerListener {
	func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
		NSLog("<-- \(GameCenterHelper.TAG) | player wantsToQuitMatch: \(player)")
	}
	
	func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
		NSLog("<-- \(GameCenterHelper.TAG) | player receivedTurnEventFor: \(player)")
	}
}

class xGKTurnBasedMatchmakerViewControllerDelegate: NSObject, GKTurnBasedMatchmakerViewControllerDelegate {
	static let instance = xGKTurnBasedMatchmakerViewControllerDelegate()
	
	func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
		NSLog("<-- \(GameCenterHelper.TAG) | turnBasedMatchmakerViewControllerWasCancelled:")
		viewController.dismiss(animated: true)
	}
	
	func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
		NSLog("<-- \(GameCenterHelper.TAG) | turnBasedMatchmakerViewController error: \(error.localizedDescription)")
	}
}

class xGKGameCenterControllerDelegate: NSObject, GKGameCenterControllerDelegate {
	static let instance = xGKGameCenterControllerDelegate()
	
	func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
		NSLog("<-- \(GameCenterHelper.TAG) | gameCenterViewControllerDidFinish")
		gameCenterViewController.dismiss(animated: true, completion: nil)
	}
}
