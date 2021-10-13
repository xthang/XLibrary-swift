//
//  Created by Thang Nguyen on 9/18/21.
//

import Foundation

class UserAlias: Codable {
	var id: Int?
	var creationTime: Date?
	var updatedTime: Date?
	var deletedTime: Date?
	var status: Int?
	var userID: Int?
	var partnerID: Int?
	var partnerUserID: String?
	var contactValue: String?
	var partnerUserFirstName: String?
	var partnerUserMiddleName: String?
	var partnerUserLastName: String?
	var linkURL: String?
	var imageURL: String?
	var friendIDs: [String]?
	
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
