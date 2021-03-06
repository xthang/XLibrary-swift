/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A struct for accessing generic password keychain items.
 */

import Foundation

public struct KeychainItem {
	// MARK: Types
	
	enum KeychainError: Error {
		case noPassword
		case unexpectedPasswordData
		case unexpectedItemData
		case unhandledError(OSStatus)
	}
	
	// MARK: Properties
	
	let service: String
	
	private(set) var account: String
	
	let accessGroup: String?
	
	// MARK: Intialization
	
	init(service: String, account: String, accessGroup: String) {
		self.service = service
		self.account = account
		self.accessGroup = accessGroup
	}
	
	// MARK: Keychain access
	
	func readItem() throws -> String {
		/*
		 Build a query to find the item that matches the service, account and
		 access group.
		 */
		var query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
		query[kSecMatchLimit as String] = kSecMatchLimitOne
		query[kSecReturnAttributes as String] = kCFBooleanTrue
		query[kSecReturnData as String] = kCFBooleanTrue
		
		// Try to fetch the existing keychain item that matches the query.
		var queryResult: AnyObject?
		let status = withUnsafeMutablePointer(to: &queryResult) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		
		// Check the return status and throw an error if appropriate.
		guard status != errSecItemNotFound else { throw KeychainError.noPassword }
		guard status == noErr else { throw KeychainError.unhandledError(status) }
		
		// Parse the password string from the query result.
		guard let existingItem = queryResult as? [String: AnyObject],
			  let passwordData = existingItem[kSecValueData as String] as? Data,
			  let password = String(data: passwordData, encoding: .utf8)
		else {
			throw KeychainError.unexpectedPasswordData
		}
		
		return password
	}
	
	func saveItem(_ password: String) throws {
		// Encode the password into an Data object.
		let encodedPassword = password.data(using: .utf8)!
		
		do {
			// Check for an existing item in the keychain.
			try _ = readItem()
			
			// Update the existing item with the new password.
			var attributesToUpdate = [String: AnyObject]()
			attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
			
			let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
			let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
			
			// Throw an error if an unexpected status was returned.
			guard status == noErr else { throw KeychainError.unhandledError(status) }
		} catch KeychainError.noPassword {
			/*
			 No password was found in the keychain. Create a dictionary to save
			 as a new keychain item.
			 */
			var newItem = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
			newItem[kSecValueData as String] = encodedPassword as AnyObject?
			
			// Add a the new item to the keychain.
			let status = SecItemAdd(newItem as CFDictionary, nil)
			
			// Throw an error if an unexpected status was returned.
			guard status == noErr else { throw KeychainError.unhandledError(status) }
		}
	}
	
	func deleteItem() throws {
		// Delete the existing item from the keychain.
		let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
		let status = SecItemDelete(query as CFDictionary)
		
		// Throw an error if an unexpected status was returned.
		guard status == noErr || status == errSecItemNotFound
		else { throw KeychainError.unhandledError(status) }
	}
	
	// MARK: Convenience
	
	private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
		var query = [String: AnyObject]()
		query[kSecClass as String] = kSecClassGenericPassword
		query[kSecAttrService as String] = service as AnyObject?
		
		if let account = account {
			query[kSecAttrAccount as String] = account as AnyObject?
		}
		
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
		}
		
		return query
	}
	
	public static func getUserIdentifier(_ tag: String, _ account: String) throws -> String? {
		do {
			let storedIdentifier = try KeychainItem(service: AppConfig.keychainIdService, account: account, accessGroup: AppConfig.keychainAccessGroup).readItem()
			return storedIdentifier
		} catch let error as KeychainError {
			if case .noPassword = error {
				return nil
			}
			// Helper.log("\(tag)|get-kch-id", error)
			throw error
		}
	}
	
	public static func saveUserInKeychain(_ account: String, _ password: String) throws {
		try KeychainItem(service: AppConfig.keychainIdService, account: account, accessGroup: AppConfig.keychainAccessGroup).saveItem(password)
	}
	
	public static func deleteUserIdentifierFromKeychain(_ account: String) throws {
		try KeychainItem(service: AppConfig.keychainIdService, account: account, accessGroup: AppConfig.keychainAccessGroup).deleteItem()
	}
	
	/*
	 For the purpose of this demo app, the user identifier will be stored in the device keychain.
	 You should store the user identifier in your account management system.
	 */
	public static var currentUserIdentifier: Int? {
		get throws {
			do {
				let storedIdentifier = try Int(KeychainItem(service: AppConfig.keychainIdService, account: AppConfig.keychainXUserIdKey, accessGroup: AppConfig.keychainAccessGroup).readItem())
				return storedIdentifier
			} catch let error as KeychainError {
				if case .noPassword = error {
					return nil
				}
				// Helper.log("get-user-id", error)
				throw error
			}
		}
	}
}
