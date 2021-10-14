//
//  Created by Thang Nguyen on 9/18/21.
//

public struct BaseRepsonse {
	var resultCode: String?
	var result: String?
	
	enum CodingKeys: String, CodingKey {
		case resultCode = "result_code"
		case result
	}
}
