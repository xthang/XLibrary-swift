//
//  Created by Thang Nguyen on 6/29/21.
//

import Foundation

import FacebookCore
import FacebookLogin

public struct FacebookHelper {
	
	private static let TAG = "Fb"
	
	
	public static func buildFacebookInfo(_ tag: Int) -> [String: Any] {
		var data: [String: Any] = [:]
		
		if let accessToken = AccessToken.current {
			// User is logged in, do work such as go to next view controller.
			var t: [String: Any] = [:]
			// t["graphDomain"] = accessToken.graphDomain
			t["tokenString"] = accessToken.tokenString
			t["appID"] = accessToken.appID
			t["userID"] = accessToken.userID
			t["permissions"] = accessToken.permissions.map({ $0.name })
			t["declinedPermissions"] = accessToken.declinedPermissions.map({ $0.name })
			t["expiredPermissions"] = accessToken.expiredPermissions.map({ $0.name })
			t["expirationDate"] = accessToken.expirationDate.description
			t["isExpired"] = accessToken.isExpired
			t["dataAccessExpirationDate"] = accessToken.dataAccessExpirationDate.description
			t["isDataAccessExpired"] = accessToken.isDataAccessExpired.description
			t["refreshDate"] = accessToken.refreshDate.description
			
			data["accessToken"] = t
		}
		
		if let authToken = AuthenticationToken.current {
			var t: [String: Any] = [:]
			t["graphDomain"] = authToken.graphDomain
			t["tokenString"] = authToken.tokenString
			t["nonce"] = authToken.nonce
			
			data["authenticationToken"] = t
		}
		
		if let fbProfile = Profile.current {
			var pf: [String: Any] = [:]
			pf["userID"] = fbProfile.userID
			pf["name"] = fbProfile.name
			pf["firstName"] = fbProfile.firstName
			pf["middleName"] = fbProfile.middleName
			pf["lastName"] = fbProfile.lastName
			pf["birthday"] = fbProfile.birthday
			pf["ageRange"] = fbProfile.ageRange
			pf["gender"] = fbProfile.gender
			pf["hometown"] = fbProfile.hometown
			pf["location"] = fbProfile.location
			pf["email"] = fbProfile.email
			pf["linkURL"] = fbProfile.linkURL
			pf["imageURL"] = fbProfile.imageURL?.description
			pf["refreshDate"] = fbProfile.refreshDate.description
			pf["friendIDs"] = fbProfile.friendIDs
			
			data["profile"] = pf
		}
		
		NSLog("--> \(TAG) | build Fb Info [\(tag)]: \(data)")
		
		return data
	}
}
