//
//  Created by Thang Nguyen on 9/18/21.
//

import Foundation

public class UserAlias: Codable {
	public var id: Int?
	public var creationTime: Date?
	public var updatedTime: Date?
	public var deletedTime: Date?
	public var status: Int?
	public var userID: Int?
	public var partnerID: Int?
	public var partnerUserID: String?
	public var contactValue: String?
	public var partnerUserFirstName: String?
	public var partnerUserMiddleName: String?
	public var partnerUserLastName: String?
	public var linkURL: String?
	public var imageURL: String?
	public var friendIDs: [String]?
	
	enum CodingKeys: String, CodingKey {
		case id
		case creationTime = "creation_time"
		case updatedTime = "updated_time"
		case deletedTime = "deleted_time"
		case status
		case userID = "user_id"
		case partnerID = "partner_id"
		case partnerUserID = "partner_user_id"
		case contactValue = "contact_value"
		case partnerUserFirstName = "partner_user_first_name"
		case partnerUserMiddleName = "partner_user_middle_name"
		case partnerUserLastName = "partner_user_last_name"
		case linkURL = "link_url"
		case imageURL = "image_url"
		case friendIDs = "friend_ids"
	}
}
