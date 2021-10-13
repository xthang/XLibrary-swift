//
//  Created by Thang Nguyen on 9/18/21.
//

import Foundation

class User: Codable {
	static var current: User?
	
	var id: Int?
	var creationTime: Date?
	var updatedTime: Date?
	var deletedTime: Date?
	var status: Int?
	var creationChannelID: Int?
	var personID: Int?
	var username: String?
	var password: String?
	var name: String?
	var img: String?
	var language: String?
	var role: Int?
	var loginTime: Date?
	var locale: String?
	var timeZone: String?
	var note: String?
	
	var currentAlias: UserAlias?
	var aliases: [UserAlias]?
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case creationTime = "creation_time"
		case updatedTime = "updated_time"
		case deletedTime = "deleted_time"
		case status
		case creationChannelID = "creation_channel_id"
		case personID = "person_id"
		case username
		case password
		case name
		case img
		case language
		case role
		case loginTime = "login_time"
		case locale
		case timeZone = "time_zone"
		case note
		
		case currentAlias
		case aliases
	}
	
	func apply(id: Int) -> User {
		self.id = id
		return self
	}
}
