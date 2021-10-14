//
//  Created by Thang Nguyen on 7/26/21.
//

import UIKit

#if SQLITE_SWIFT_STANDALONE
import sqlite3
#elseif SQLITE_SWIFT_SQLCIPHER
import SQLCipher
#elseif os(Linux)
import CSQLite
#else
import SQLite3
#endif

public class ScoreData {
	private static let TAG = "Db"
	
	static var path : String = "xDB.sqlite"
	
	//	static func saveLocalScore(_ score: Int) {
	//		let scores = UserDefaults.standard.mutableArrayValue(forKey: AppConfig.scoresKey)
	//		scores.add(["score": score, "time": Date()] as Any)
	//	}
	//
	//	static func getBestLocalScore() -> Int? {
	//		if let scores = UserDefaults.standard.array(forKey: AppConfig.scoresKey) as? [Score] {
	//			if scores.count > 0 {
	//				let max = scores.max { a, b in
	//					return a.score < b.score
	//				}
	//				return max?.score
	//			}
	//		}
	//		return nil
	//	}
	
	static func createOrOpenDB() -> OpaquePointer? {
		let filePath = try! FileManager.default
			.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent(path)
		//		let filePath = NSSearchPathForDirectoriesInDomains(
		//			.documentDirectory, .userDomainMask, true
		//		).first!
		// NSLog("--  \(TAG) | db path: \(filePath)")
		
		var db : OpaquePointer? = nil
		
		if sqlite3_open("\(filePath.path)", &db) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("--  \(TAG) | error in opening/ creating DB: \(errmsg)")
			close(db)
			return nil
		}
		
		// NSLog("--  \(TAG) | Database has been openned/ created with path: \(path)")
		return db
	}
	
	static func close(_ db: OpaquePointer?) {
		if sqlite3_close(db) != SQLITE_OK {
			NSLog("!-  \(TAG) | error closing database")
		} else {
			// NSLog("--  \(TAG) | close DB OK")
		}
	}
	
	static func createTable(_ db: OpaquePointer) -> Bool {
		let query = "CREATE TABLE IF NOT EXISTS swipe_score(id INTEGER PRIMARY KEY AUTOINCREMENT, time DATETIME, score INTEGER, player_id CHAR(255), player_name TEXT);"
		
		if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error creating table: \(errmsg)")
			return false
		}
		
		// NSLog("--  \(TAG) | Table creation success")
		return true
	}
	
	static func printTableInfo(_ db: OpaquePointer) {
		let query = "PRAGMA table_info('swipe_score');"
		var statement : OpaquePointer? = nil
		defer {
			let _ = finalize(db, statement)
		}
		
		if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
			while(sqlite3_step(statement) == SQLITE_ROW) {
				NSLog("--  \(TAG) | column: \(String(cString: sqlite3_column_text(statement, 1))) -- type: \(String(cString: sqlite3_column_text(statement, 2)))")
			}
		}
	}
	
	static func finalize(_ db: OpaquePointer?, _ statement: OpaquePointer?) -> Bool {
		if sqlite3_finalize(statement) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error finalizing prepared statement: \(errmsg)")
			return false
		}
		// NSLog("--  \(TAG) | finalize statement OK")
		return true
	}
	
	public static func insert(_ scores: [Score]) -> [Score]? {
		NSLog("--  \(TAG) | inserting: \(scores.count)")
		guard let db = createOrOpenDB(), createTable(db) else { return nil }
		defer {
			close(db)
		}
		
		let query = "INSERT INTO swipe_score (time, score, player_id, player_name) VALUES (?, ?, ?, ?);"
		var statement : OpaquePointer? = nil
		defer {
			let _ = finalize(db, statement)
		}
		
		if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error preparing insert: \(errmsg)")
			return nil
		}
		
		var fails = [Score]()
		for score in scores {
			sqlite3_bind_double(statement, 1, score.time.timeIntervalSinceReferenceDate)
			sqlite3_bind_int(statement, 2, Int32(score.score))
			if #available(iOS 12.4, *) {
				sqlite3_bind_text(statement, 3, score.player.gkPlayer.teamPlayerID, -1, nil)
			} else {
				sqlite3_bind_text(statement, 3, score.player.gkPlayer.playerID, -1, nil)
			}
			sqlite3_bind_text(statement, 4, score.player.gkPlayer.displayName, -1, nil)
			
			if sqlite3_step(statement) != SQLITE_DONE {
				let errmsg = String(cString: sqlite3_errmsg(db)!)
				NSLog("!-  \(TAG) | error inserting data: \(score) \n| \(errmsg)")
				fails.append(score)
			} else {
				// NSLog("--  \(TAG) | insert done: \(score)")
			}
			
			if sqlite3_reset(statement) != SQLITE_OK {
				let errmsg = String(cString: sqlite3_errmsg(db)!)
				NSLog("!-  \(TAG) | error resetting prepared statement: \(errmsg)")
			}
		}
		
		NSLog("--  \(TAG) | Data inserted with fails: \(fails)")
		return fails
	}
	
	public static func insert(_ score: Score) -> Bool {
		let rs = insert([score])
		if rs == nil || rs!.count > 0 { return false }
		return true
	}
	
	public static func getHighests(limit: Int) -> [Score]? {
		guard let db = createOrOpenDB(), createTable(db) else { return nil }
		defer {
			close(db)
		}
		
		var scores = [Score]()
		
		let query = "SELECT id, time, score, player_id, player_name FROM swipe_score ORDER BY score DESC, time DESC LIMIT ?;"
		var statement : OpaquePointer? = nil
		defer {
			let _ = finalize(db, statement)
		}
		
		if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error preparing insert: \(errmsg)")
			return nil
		}
		sqlite3_bind_int(statement, 1, Int32(limit))
		while sqlite3_step(statement) == SQLITE_ROW {
			//NSLog ("--  \(TAG) | \(sqlite3_column_type(statement, 1)) | \(sqlite3_column_text(statement, 1))")
			let score = Score(-1)
			if sqlite3_column_type(statement, 0) != SQLITE_NULL { score.id = Int(sqlite3_column_int(statement, 0)) }
			if sqlite3_column_type(statement, 1) != SQLITE_NULL { score.time = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(statement, 1)) }
			if sqlite3_column_type(statement, 2) != SQLITE_NULL { score.score = Int(sqlite3_column_int(statement, 2)) }
			if let x = sqlite3_column_text(statement, 3) { score.player.playerID = String(cString: x) }
			if let x = sqlite3_column_text(statement, 4) { score.player.name = String(cString: x) }
			
			scores.append(score)
		}
		
		// NSLog("--  \(TAG) | top scores: \(scores)")
		return scores
	}
	
	public static func getHishest() -> Score? {
		return getHighests(limit: 1)?.first
	}
	
	static func update(_ score: Score) -> Bool {
		guard let db = createOrOpenDB(), createTable(db) else { return false }
		defer {
			close(db)
		}
		
		let query = "UPDATE swipe_score SET score = \(score.score) WHERE id = \(score.id!);"
		var statement : OpaquePointer? = nil
		defer {
			let _ = finalize(db, statement)
		}
		
		if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error preparing sql: \(errmsg)")
			return false
		}
		if sqlite3_step(statement) != SQLITE_DONE {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error updating data: \(errmsg)")
			return false
		}
		
		NSLog("--  \(TAG) | Data updated success")
		return true
		
	}
	
	static func delete(id : Int) -> Bool {
		guard let db = createOrOpenDB(), createTable(db) else { return false }
		defer {
			close(db)
		}
		
		let query = "DELETE FROM swipe_score WHERE id = \(id)"
		var statement : OpaquePointer? = nil
		defer {
			let _ = finalize(db, statement)
		}
		
		if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error preparing sql: \(errmsg)")
			return false
		}
		if sqlite3_step(statement) != SQLITE_DONE {
			let errmsg = String(cString: sqlite3_errmsg(db)!)
			NSLog("!-  \(TAG) | error deleting data: \(errmsg)")
			return false
		}
		
		NSLog("--  \(TAG) | Data delete success")
		return true
	}
}
