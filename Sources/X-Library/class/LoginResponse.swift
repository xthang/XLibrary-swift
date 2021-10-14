//
//  Created by Thang Nguyen on 9/18/21.
//

public struct LoginRepsonse: Codable {
	var resultCode: String?
	var result: String?
	
	var statusCode: Int?
	var user: User?
	var isNew: Bool?
	
	enum CodingKeys: String, CodingKey {
		case resultCode = "result_code"
		case result
		
		case statusCode = "status_code"
		case user
		case isNew
	}
}
