//
//  Created by Thang Nguyen on 9/18/21.
//

struct UnlinkAccountRepsonse: Codable {
	var resultCode: String?
	var result: String?
	
	var accountState: Int?
	var user: User?
	
	enum CodingKeys: String, CodingKey {
		case resultCode = "result_code"
		case result
		
		case accountState = "account_state"
		case user
	}
}
