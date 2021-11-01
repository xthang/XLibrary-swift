//
//  Created by Thang Nguyen on 9/18/21.
//

import AuthenticationServices

import FBSDKLoginKit

public struct AuthenticationHelper {
	
	private static let TAG = "🔑"
	
	public static func signIn(_ tag: Int, _ authMethod: Int, authPartner: String?, userInfo: User?, partnerAuthData: [String: Any?]?, completion: @escaping (_ ok: Bool, _ msg: String?) -> Void) {
		NSLog("--> \(TAG) | [log in] [\(tag)] ...: \(authMethod) | \(authPartner as Any? ?? "--") | \(userInfo as Any? ?? "--") | \(partnerAuthData as Any? ?? "--")")
		
		var errors: [String: Any] = [:]
		let app = Helper.buildAppInfo("\(tag)|sign-in", &errors)
		let device = try! Helper.buildDeviceInfo("\(tag)|sign-in", &errors, false)
		let system = Helper.buildSystemInfo("\(tag)|sign-in", &errors)
		
		let url = URL(string: "https://xthang.xyz/account/sign-in-api.php")!
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("ios", forHTTPHeaderField: "platform")
		request.setValue("1", forHTTPHeaderField: "eco-system-id")
		request.httpBody = try? JSONSerialization.data(withJSONObject: [
			"app": app,
			"device": device,
			"system": system,
			"auth-method": authMethod,
			"auth-partner": authPartner,
			"user": JSONSerialization.jsonObject(with: JSONEncoder().encode(userInfo), options: .allowFragments) as? [String: Any],
			"partner-auth-data": partnerAuthData,
			"errors": !errors.isEmpty ? errors : nil
		], options: [])
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
			let stt = (response as? HTTPURLResponse)?.statusCode
			let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
			NSLog("<-- \(TAG) | [sign in] rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
			
			if error != nil {
				let msg = "[sign in] [\(tag).1] < Something is wrong >"
				Snackbar.e(msg)
				completion(false, msg)
				return
			}
			if let d = data {
				do {
					let jsonDecoder = JSONDecoder()
					jsonDecoder.dateDecodingStrategy = .formatted(CommonConfig.dateFormatter)
					let rsp = try jsonDecoder.decode(LoginRepsonse.self, from: d)
					
					NSLog("--  \(TAG) | [sign in] result: \(rsp.resultCode ?? "--") | \(rsp.result ?? "--") | \(rsp.isNew as Any? ?? "--") | \(rsp.statusCode as Any? ?? "--") | \(rsp.user as Any? ?? "--")")
					
					if rsp.statusCode == -1 {	// User not found
						User.current = rsp.user
						try KeychainItem.deleteUserIdentifierFromKeychain(AppConfig.keychainXUserIdKey)
						
						DispatchQueue.main.async {
							NotificationCenter.default.post(name: .xAuthStateChanged, object: false)
						}
						let msg = "[sign in] [\(tag).3] \(rsp.result ?? "< Account is deleted >")"
						processCompletion(false, msg, completion)
						return
					}
					if stt != 200 {
						let msg = "[sign in] [\(tag).4] [\(stt as Any? ?? "")] \(rsp.result ?? "< Something is wrong >")"
						processCompletion(false, msg, completion)
						return
					}
					if rsp.resultCode != nil {
						let msg = "[sign in] [\(tag).5] \(rsp.result ?? "< Something is wrong >")"
						processCompletion(false, msg, completion)
						return
					}
					
					User.current = rsp.user
					try KeychainItem.saveUserInKeychain(AppConfig.keychainXUserIdKey, "\(rsp.user!.id!)")
					
					DispatchQueue.main.async {
						NotificationCenter.default.post(name: .xAuthStateChanged, object: true)
					}
					let msg = "[\(tag)] \(rsp.result ?? "< Sign in successfully >")"
					processCompletion(true, msg, completion)
					
					if let aliases = rsp.user?.aliases {
						for alias in aliases {
							if alias.partnerID == Partner.ID.appleID.rawValue {
								if let userID = alias.partnerUserID {
									getAppleIDCredentialState(userID: userID, alias: alias)
								}
							} else if alias.partnerID == Partner.ID.facebook.rawValue {
								if let _ = alias.partnerUserID {
									DispatchQueue.main.async {
										NotificationCenter.default.post(name: .fbStateChanged, object: [
											"credentialState": Partner.CredentialState.authorized,
											"alias": alias
										])
									}
								}
							}
						}
					}
				} catch let error as KeychainItem.KeychainError {
					NSLog("!-- \(TAG) | [sign in] update Keychain error: \(error)")
					let msg = "[sign in] [\(tag)] < update Keychain error >"
					processCompletion(false, msg, completion)
					Helper.log("signin-Keychain", error)
				} catch {
					NSLog("!-- \(TAG) | [sign in] decode error: \(error)")
					let msg = "[sign in] [\(tag)] < decode error >"
					processCompletion(false, msg, completion)
					let idx = dataStr?.firstIndex(of: "{")
					Helper.log("signin", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
				}
			} else {
				NSLog("!-- \(TAG) | [sign in] data is null")
				let msg = "[sign in] [\(tag)] < data is null >"
				processCompletion(false, msg, completion)
			}
		})
		
		task.resume()
	}
	
	static private func processCompletion(_ successful: Bool, _ msg: String, _ completion: @escaping (_ ok: Bool, _ msg: String?) -> Void) {
		Snackbar.show(msg, successful ? .s : .e)
		completion(successful, msg)
	}
	
	public static func getAppleIDCredentialState(userID: String, alias: UserAlias) {
		NSLog("--> \(TAG) |  get CredentialState ...: forUserID: \(userID)")
		
		if #available(iOS 13.0, *) {
			let appleIDProvider = ASAuthorizationAppleIDProvider()
			appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
				NSLog("--  \(TAG) |  get CredentialState -> \(credentialState.rawValue) | !!- \(error?.localizedDescription ?? "")")
				if (error != nil) { Snackbar.e(" get CredentialState -> \(credentialState.rawValue) | error: \(error!.localizedDescription)") }
				
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: .appleIDStateChanged, object: [
						"credentialState": credentialState.toPartnerState(),
						"alias": alias,
						"error": error as Any
					])
				}
			}
		} else {
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .appleIDStateChanged, object: [
					"credentialState": Partner.CredentialState.undefined,
					"alias": alias,
					"msg": "iOS not supported"
				])
			}
		}
	}
	
	public static func signOut(_ tag: Int, completion: @escaping (_ ok: Bool, _ msg: String?) -> Void) {
		NSLog("--> \(TAG) | [Sign out X] [\(tag)] ...")
		do {
			// todo: call API if neccessary
			
			try KeychainItem.deleteUserIdentifierFromKeychain(AppConfig.keychainXUserIdKey)
			User.current = nil
			NotificationCenter.default.post(name: .xAuthStateChanged, object: false)
			
			// update linked Accounts
			NotificationCenter.default.post(name: .appleIDStateChanged, object: [
				"credentialState": Partner.CredentialState.revoked,
				"msg": "Signed out"
			])
			LoginManager().logOut()
			NotificationCenter.default.post(name: .fbStateChanged, object: [
				"credentialState": Partner.CredentialState.revoked,
				"msg": "Signed out"
			])
			// todo: gc, fb, eos
			
			let msg = "[\(tag)] Signed out successfully"
			Snackbar.s(msg)
			completion(true, msg)
		} catch {
			NSLog("--  \(TAG) | [Sign out X] error: %s", error.localizedDescription)
			let msg = "[\(tag)] Sign out X < Something is wrong >"
			Snackbar.e(msg)
			completion(false, msg)
			Helper.log("signout", error)
		}
	}
	
	public static func unlinkAccount(_ tag: Int, userInfo: User, alias: UserAlias, completion: @escaping (_ ok: Bool, _ msg: String?) -> Void) {
		NSLog("--> \(TAG) | [unlink Acc] [\(tag)] ...: \(userInfo) | \(alias)")
		
		var errors: [String: Any] = [:]
		let app: [String: Any] = Helper.buildAppInfo("\(tag)|unlink", &errors)
		
		let url = URL(string: "https://xthang.xyz/account/unlink-account-api.php")!
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("ios", forHTTPHeaderField: "platform")
		request.setValue("1", forHTTPHeaderField: "eco-system-id")
		request.httpBody = try? JSONSerialization.data(withJSONObject: [
			"app": app,
			"user": JSONSerialization.jsonObject(with: JSONEncoder().encode(userInfo), options: .allowFragments),
			"alias": JSONSerialization.jsonObject(with: JSONEncoder().encode(alias), options: .allowFragments),
			"errors": !errors.isEmpty ? errors : nil
		], options: [])
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
			let stt = (response as? HTTPURLResponse)?.statusCode
			let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
			NSLog("<-- \(TAG) | [unlink Acc] rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
			
			if error != nil {
				let msg = "[unlink Acc] [\(tag).1] < Something is wrong >"
				Snackbar.e(msg)
				completion(false, msg)
				return
			}
			if let d = data {
				do {
					let jsonDecoder = JSONDecoder()
					jsonDecoder.dateDecodingStrategy = .formatted(CommonConfig.dateFormatter)
					let rsp = try jsonDecoder.decode(UnlinkAccountRepsonse.self, from: d)
					
					NSLog("--  \(TAG) | [unlink Acc] result: \(rsp.resultCode ?? "--") | \(rsp.result ?? "--") | \(rsp.user as Any? ?? "--")")
					
					defer {
						var flag_Apple = false
						var flag_Fb = false
						if let aliases = rsp.user?.aliases {
							for a in aliases {
								if a.partnerID == Partner.ID.appleID.rawValue {
									if let _ = a.partnerUserID {
										DispatchQueue.main.async {
											NotificationCenter.default.post(name: .appleIDStateChanged, object: [
												"credentialState": Partner.CredentialState.authorized,
												"alias": a
											])
										}
										flag_Apple = true
									}
								} else if a.partnerID == Partner.ID.facebook.rawValue {
									if let _ = a.partnerUserID {
										DispatchQueue.main.async {
											NotificationCenter.default.post(name: .fbStateChanged, object: [
												"credentialState": Partner.CredentialState.authorized,
												"alias": a
											])
										}
										flag_Fb = true
									}
								}
							}
						}
						
						if !flag_Apple {
							DispatchQueue.main.async {
								NotificationCenter.default.post(name: .appleIDStateChanged, object: [
									"credentialState": Partner.CredentialState.notFound
								])
							}
						}
						if !flag_Fb {
							DispatchQueue.main.async {
								NotificationCenter.default.post(name: .fbStateChanged, object: [
									"credentialState": Partner.CredentialState.notFound
								])
							}
						}
					}
					
					if rsp.accountState == -1 {
						User.current = rsp.user
						try KeychainItem.deleteUserIdentifierFromKeychain(AppConfig.keychainXUserIdKey)
						let msg = "[unlink] [\(tag).4] \(rsp.result ?? "< Account is deleted >")"
						Snackbar.e(msg)
						completion(false, msg)
						return
					}
					if stt != 200 {
						let msg = "[unlink] [\(tag).5] [\(stt as Any? ?? "")] \(rsp.result ?? "< Something is wrong >")"
						Snackbar.e(msg)
						completion(false, msg)
						return
					}
					if rsp.resultCode != nil {
						let msg = "[unlink] [\(tag).6] \(rsp.result ?? "< Something is wrong >")"
						Snackbar.e(msg)
						completion(false, msg)
						return
					}
					
					User.current = rsp.user
					
					let msg = "[\(tag)] \(rsp.result ?? "< Unlink successfully >")"
					Snackbar.s(msg)
					
					if (Partner.ID(rawValue: alias.partnerID!) == .appleID) {
						DispatchQueue.main.async {
							NotificationCenter.default.post(name: .appleIDStateChanged, object: [
								"credentialState": Partner.CredentialState.revoked,
								"msg": "Unlinked"
							])
						}
					} else if (Partner.ID(rawValue: alias.partnerID!) == .facebook) {
						DispatchQueue.main.async {
							NotificationCenter.default.post(name: .fbStateChanged, object: [
								"credentialState": Partner.CredentialState.revoked,
								"msg": "Unlinked"
							])
						}
					} else {
						NSLog("!-- \(TAG) | [unlink Acc] WTH is this account?")
						Snackbar.w("< WTH is this account? >")
					}
					
					completion(true, msg)
				} catch {
					NSLog("!-- \(TAG) | [unlink Acc] decode error: \(error)")
					let msg = "[\(tag).3] Unlink account < Something is wrong >"
					Snackbar.e(msg)
					completion(false, msg)
					let idx = dataStr?.firstIndex(of: "{")
					Helper.log("unlink-acc-decode", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
				}
			} else {
				NSLog("!-- \(TAG) | [unlink Acc] data is null")
				let msg = "[\(tag).2] Unlink account < Something is wrong >"
				Snackbar.e(msg)
				completion(false, msg)
			}
		})
		
		task.resume()
	}
}
