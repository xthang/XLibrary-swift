//
//  Created by Thang Nguyen on 9/19/21.
//

public struct Partner {
	public enum ID: Int {
		case facebook = 2
		case appleID = 3
	}
	
	public enum CredentialState: Int {
		case undefined = -1
		case revoked = 0
		case authorized = 1
		case notFound = 2
		case transferred = 3
	}
}
