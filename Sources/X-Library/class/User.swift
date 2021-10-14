//
//  Created by Thang Nguyen on 9/18/21.
//

import Foundation

public class User: Codable {
	public static var current: User?
	
	public var id: Int?
	public var creationTime: Date?
	public var updatedTime: Date?
	public var deletedTime: Date?
	public var status: Int?
	public var creationChannelID: Int?
	public var personID: Int?
	public var username: String?
	public var password: String?
	public var name: String?
	public var img: String?
	public var language: String?
	public var role: Int?
	public var loginTime: Date?
	public var locale: String?
	public var timeZone: String?
	public var note: String?
	
	public var currentAlias: UserAlias?
	public var aliases: [UserAlias]?
	
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
	
	public init() { }
	
	public func apply(id: Int) -> User {
		self.id = id
		return self
	}
}
