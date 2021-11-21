//
//  Created by Thang Nguyen on 6/29/21.
//

import UIKit
import SystemConfiguration
import AdSupport
import CoreTelephony
import AVFoundation
import GameKit

public struct Helper {
	
	private static let TAG = "🧰"
	
	public static var soundOn: Bool {
		return UserDefaults.standard.object(forKey: CommonConfig.Settings.sound) as? Bool ?? true
	}
	public static var soundVolume: Float {
		return UserDefaults.standard.object(forKey: CommonConfig.Settings.sound_volume) as? Float ?? 0.7
	}
	public static var musicOn: Bool {
		return UserDefaults.standard.object(forKey: CommonConfig.Settings.music) as? Bool ?? true
	}
	public static var musicVolume: Float {
		return UserDefaults.standard.object(forKey: CommonConfig.Settings.music_volume) as? Float ?? 0.7
	}
	public static var vibrationOn: Bool {
		return UserDefaults.standard.object(forKey: CommonConfig.Settings.vibration) as? Bool ?? true
	}
	public static var isFirstRun: Bool {
		return UserDefaults.standard.object(forKey: "is_first_run") as? Bool ?? true
	}
	public static func setNotFirstRun() {
		UserDefaults.standard.set(false, forKey: "is_first_run")
	}
	public static var adsRemoved: Bool {
		return UserDefaults.standard.stringArray(forKey: CommonConfig.Keys.purchased)?.contains(AdsStore.shared.adsRemovalID) ?? false
	}
	
	public static func buildAppInfo(_ tag: String, _ err: inout [String: Any]) -> [String: Any] {
		var app: [String: Any] = [:]
		
		app["id"] = AppConfig.appID	// db table Application
		if let info = Bundle.main.infoDictionary {
			app["CFBundleName"] = info["CFBundleName"]
			app["CFBundleDisplayName"] = info["CFBundleDisplayName"]
			app["CFBundleIdentifier"] = info["CFBundleIdentifier"]
			app["CFBundleVersion"] = info["CFBundleVersion"]
			app["CFBundleNumericVersion"] = info["CFBundleNumericVersion"]
			app["CFBundleShortVersionString"] = info["CFBundleShortVersionString"]
			app["AppIdentifierPrefix"] = info["AppIdentifierPrefix"]
		}
		
		return app
	}
	
	public static func buildUsersInfo(_ tag: String, _ err: inout [String: Any], _ suppressError: Bool) throws -> [String: Any] {
		var data: [String: Any] = [:]	// why 'Any' ?: in case a value is nil, the value is set to null
		
		do {
			let xUserID = try KeychainItem.currentUserIdentifier
			data["ids"] = xUserID != nil ? [ xUserID ] : nil
			data["current-id"] = xUserID
		} catch {
			if !suppressError { throw error }
			else { err["user-info"] = "[\(tag)] \(error)" }
		}
		
		var gamePlayer: [String: Any] = [:]
		gamePlayer["playerID"] = GKLocalPlayer.local.playerID
		gamePlayer["guestIdentifier"] = GKLocalPlayer.local.guestIdentifier
		gamePlayer["alias"] = GKLocalPlayer.local.alias
		gamePlayer["displayName"] = GKLocalPlayer.local.displayName
		gamePlayer["friends"] = GKLocalPlayer.local.friends?.count
		gamePlayer["isFriend"] = GKLocalPlayer.local.isFriend
		gamePlayer["isAuthenticated"] = GKLocalPlayer.local.isAuthenticated
		gamePlayer["isUnderage"] = GKLocalPlayer.local.isUnderage
		if #available(iOS 12.4, *) {
			gamePlayer["gamePlayerID"] = GKLocalPlayer.local.gamePlayerID
			gamePlayer["teamPlayerID"] = GKLocalPlayer.local.teamPlayerID
		}
		if #available(iOS 13.0, *) {
			gamePlayer["isMultiplayerGamingRestricted"] = GKLocalPlayer.local.isMultiplayerGamingRestricted
		}
		if #available(iOS 14.0, *) {
			gamePlayer["isInvitable"] = GKLocalPlayer.local.isInvitable
			gamePlayer["isPersonalizedCommunicationRestricted"] = GKLocalPlayer.local.isPersonalizedCommunicationRestricted
		}
		data["game-player"] = gamePlayer
		
		NSLog("--> \(TAG) | build Users Info [\(tag)]: \(data)")
		
		return data
	}
	
	public static func buildDeviceInfo(_ tag: String, _ err: inout [String: Any], _ suppressError: Bool) throws -> [String: Any] {
		var device: [String: Any] = [:]
		
		do {
			device["uid"] = try KeychainItem.getUserIdentifier("\(tag)|device-info", AppConfig.keychainDeviceIdKey)
		} catch {
			if !suppressError { throw error }
			else { err["device-info"] = "[\(tag)] \(error)" }
		}
		
		device["model-id"] = UIDevice.modelID
		device["model"] = UIDevice.current.model
		device["localizedModel"] = UIDevice.current.localizedModel
		device["SIMULATOR_MODEL_IDENTIFIER"] = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]
		
		device["identifierForVendor"] = UIDevice.current.identifierForVendor?.uuidString
		device["advertisingIdentifier"] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
		
		device["systemName"] = UIDevice.current.systemName
		device["systemVersion"] = UIDevice.current.systemVersion
		
		device["name"] = UIDevice.current.name
		
		device["isBatteryMonitoringEnabled"] = UIDevice.current.isBatteryMonitoringEnabled
		device["batteryLevel"] = UIDevice.current.batteryLevel
		device["batteryState"] = UIDevice.current.batteryState.rawValue
		
		device["isProximityMonitoringEnabled"] = UIDevice.current.isProximityMonitoringEnabled
		device["proximityState"] = UIDevice.current.proximityState
		
		device["isGeneratingDeviceOrientationNotifications"] = UIDevice.current.isGeneratingDeviceOrientationNotifications
		device["orientation"] = UIDevice.current.orientation.rawValue
		
		device["userInterfaceIdiom"] = UIDevice.current.userInterfaceIdiom.rawValue
		device["isMultitaskingSupported"] = UIDevice.current.isMultitaskingSupported
		
		device["TARGET_OS_SIMULATOR"] = TARGET_OS_SIMULATOR
		device["local_arch"] = Device.getLocalArch()
		
		device["systemSize"] = Device.systemSizeInBytes
		device["systemFreeSize"] = Device.systemFreeSizeInBytes
		
		device["screens"] = UIScreen.screens.map({ s -> [String: Any] in
			var x: [String: Any] = [
				"traitCollection": s.traitCollection.description,
				"width": s.bounds.size.width,
				"height": s.bounds.size.height,
				"nativeScale": s.nativeScale,
				"scale": s.scale,
				"availableModes": s.availableModes.map({ $0.description }),
				"brightness": s.brightness,
				"wantsSoftwareDimming": s.wantsSoftwareDimming,
				"coordinateSpace": s.coordinateSpace.description,
				"fixedCoordinateSpace": s.fixedCoordinateSpace.description,
			]
			
			x["preferredMode"] = s.preferredMode?.description
			x["currentMode"] = s.currentMode?.description
			x["mirrored"] = s.mirrored?.description
			
			if #available(iOS 10.3, *) {
				x["maximumFramesPerSecond"] = s.maximumFramesPerSecond
			}
			if #available(iOS 11.0, *) {
				x["isCaptured"] = s.isCaptured
			}
			if #available(iOS 13.0, *) {
				x["calibratedLatency"] = s.calibratedLatency
			}
			
			return x
		})
		
		if tag.contains("|cfg") { NSLog("--> \(TAG) | build Device Info [\(tag)]: \(device)") }
		
		return device
	}
	
	public static func buildSystemInfo(_ tag: String, _ err: inout [String: Any]) -> [String: Any] {
		var data: [String: Any] = [:]
		
		data["locale"] = Locale.current.identifier
		data["timeZone"] = TimeZone.current.identifier
		
		var jb: [String: Any] = [:]
		jb["hasCydiaInstalled"] = JailBrakeHelper.hasCydiaInstalled()
		jb["isContainsSuspiciousApps"] = JailBrakeHelper.isContainsSuspiciousApps()
		jb["isSuspiciousSystemPathsExists"] = JailBrakeHelper.isSuspiciousSystemPathsExists()
		jb["canEditSystemFiles"] = JailBrakeHelper.canEditSystemFiles()
		
		data["jailbreak"] = jb
		
		data["isProtectedDataAvailable"] = UIApplication.shared.isProtectedDataAvailable
		
		if tag.contains("|cfg") { NSLog("--> \(TAG) | build System Info [\(tag)]: \(data)") }
		
		return data
	}
	
	private static func buildProcessInfo(_ tag: Int, _ err: inout [String: Any]) -> [String: Any] {
		var data: [String: Any] = [:]
		
		let processInfo = ProcessInfo.processInfo
		data["environment"] = processInfo.environment
		data["arguments"] = processInfo.arguments
		// data["hostName"] = processInfo.hostName	// this makes app lag on first run, and then open popup to require access to local network. It also returns: xPhone, xPad
		data["processName"] = processInfo.processName
		data["processIdentifier"] = processInfo.processIdentifier
		data["globallyUniqueString"] = processInfo.globallyUniqueString
		data["operatingSystem"] = processInfo.operatingSystem()
		data["operatingSystemName"] = processInfo.operatingSystemName()
		let v = processInfo.operatingSystemVersion
		data["operatingSystemVersion"] = "\(v.majorVersion)-\(v.minorVersion)-\(v.patchVersion)"
		data["operatingSystemVersionString"] = processInfo.operatingSystemVersionString
		data["processorCount"] = processInfo.processorCount
		data["activeProcessorCount"] = processInfo.activeProcessorCount
		data["physicalMemory"] = processInfo.physicalMemory
		data["systemUptime"] = processInfo.systemUptime
		data["isLowPowerModeEnabled"] = processInfo.isLowPowerModeEnabled
		if #available(iOS 11.0, *) {
			data["thermalState"] = processInfo.thermalState.rawValue
		}
		if #available(iOS 13.0, *) {
			data["isMacCatalystApp"] = processInfo.isMacCatalystApp
		}
		if #available(iOS 14.0, *) {
			data["isiOSAppOnMac"] = processInfo.isiOSAppOnMac
		}
		
		if tag == 1 { NSLog("--> \(TAG) | build Process Info [\(tag)]: \(data)") }
		
		return data
	}
	
	private static func buildTelephonyInfo(_ tag: Int, _ err: inout [String: Any]) -> [String: Any] {
		var info: [String: Any] = [:]
		
		let networkInfo = CTTelephonyNetworkInfo()
		if #available(iOS 12.0, *) {
			if let networkOperators = networkInfo.serviceSubscriberCellularProviders {
				info["networkOperators"] = networkOperators.mapValues({ value in buildNetworkOperatorInfo(value) })
			}
			info["serviceCurrentRadioAccessTechnology"] = networkInfo.serviceCurrentRadioAccessTechnology
		} else {
			if let networkOperator = networkInfo.subscriberCellularProvider {
				info["networkOperator"] = buildNetworkOperatorInfo(networkOperator)
			}
			info["currentRadioAccessTechnology"] = networkInfo.currentRadioAccessTechnology
		}
		if #available(iOS 13.0, *) {
			info["dataServiceIdentifier"] = networkInfo.dataServiceIdentifier
		}
		
		if #available(iOS 12.1, *) {
			info["subscribers"] = CTSubscriberInfo.subscribers().map({["carrierToken": $0.carrierToken as Any, "identifier": $0.identifier]})
		} else {
			info["subscriber"] = ["carrierToken": CTSubscriberInfo.subscriber().carrierToken as Any]
		}
		
		if tag == 1 { NSLog("--> \(TAG) | build Telephony Info [\(tag)]: \(info)") }
		
		return info
	}
	
	private static func buildNetworkOperatorInfo(_ networkOperator: CTCarrier) -> [String: Any] {
		var info: [String: Any] = [:]
		
		info["networkOperatorName"] = networkOperator.carrierName
		info["isoCountryCode"] = networkOperator.isoCountryCode
		info["mobileCountryCode"] = networkOperator.mobileCountryCode
		info["mobileNetworkCode"] = networkOperator.mobileNetworkCode
		info["allowsVOIP"] = networkOperator.allowsVOIP
		
		return info
	}
	
	private static func buildConnectivityInfo(_ tag: Int, _ err: inout [String: Any]) -> [String: Any] {
		var info: [String: Any] = [:]
		
		info["is_connected_to_network"] = Device.isConnectedToNetwork()
		
		info["networks"] = Device.getCurrentNetworksInfo()
		
		if let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") {
			var networkReachabilityFlags = SCNetworkReachabilityFlags()
			let _ = SCNetworkReachabilityGetFlags(reachability, &networkReachabilityFlags)
			
			var nr: [String: Any] = [:]
			nr["transientConnection"] = networkReachabilityFlags.contains(.transientConnection)
			nr["reachable"] = networkReachabilityFlags.contains(.reachable)
			nr["connectionRequired"] = networkReachabilityFlags.contains(.connectionRequired)
			nr["connectionOnTraffic"] = networkReachabilityFlags.contains(.connectionOnTraffic)
			nr["interventionRequired"] = networkReachabilityFlags.contains(.interventionRequired)
			nr["connectionOnDemand"] = networkReachabilityFlags.contains(.connectionOnDemand)
			nr["isLocalAddress"] = networkReachabilityFlags.contains(.isLocalAddress)
			nr["isDirect"] = networkReachabilityFlags.contains(.isDirect)
			nr["isWWAN"] = networkReachabilityFlags.contains(.isWWAN)
			nr["connectionAutomatic"] = networkReachabilityFlags.contains(.connectionAutomatic)
			
			info["networkReachability"] = nr
		}
		
		info["addresses"] = Device.getAddresses()
		
		if tag == 1 { NSLog("--> \(TAG) | build Connectivity Info [\(tag)]: \(info)") }
		
		return info
	}
	
	private static func buildAudioInfo(_ tag: Int, _ err: inout [String: Any]) -> [String: Any] {
		var info: [String: Any] = [:]
		
		let aSession = AVAudioSession.sharedInstance()
		
		var s: [String: Any] = [:]
		s["category"] = aSession.category.rawValue
		s["mode"] = aSession.mode.rawValue
		s["recordPermission"] = aSession.recordPermission.rawValue
		s["isInputAvailable"] = aSession.isInputAvailable
		s["inputDataSource"] = aSession.inputDataSource?.dataSourceName
		s["outputDataSource"] = aSession.outputDataSource?.dataSourceName
		s["sampleRate"] = aSession.sampleRate
		s["isOtherAudioPlaying"] = aSession.isOtherAudioPlaying
		s["secondaryAudioShouldBeSilencedHint"] = aSession.secondaryAudioShouldBeSilencedHint
		s["outputVolume"] = aSession.outputVolume
		if #available(iOS 11.0, *) {
			s["routeSharingPolicy"] = aSession.routeSharingPolicy.rawValue
		}
		if #available(iOS 13.0, *) {
			s["promptStyle"] = aSession.promptStyle.rawValue
		}
		
		info["session"] = s
		
		info["bluetooth_audio_connected"] = Device.bluetoothAudioConnected()
		
		if tag == 1 { NSLog("--> \(TAG) | build Audio Info [\(tag)]: \(info)") }
		
		return info
	}
	
	private static func buildUserConfigInfo(_ tag: Int, _ err: inout [String: Any]) -> [String: Any] {
		var userSettings: [String: Any] = [:]
		
		userSettings["music"] = UserDefaults.standard.object(forKey: CommonConfig.Settings.music)
		userSettings["music-volume"] = UserDefaults.standard.object(forKey: CommonConfig.Settings.music_volume)
		userSettings["sound"] = UserDefaults.standard.object(forKey: CommonConfig.Settings.sound)
		userSettings["sound-volume"] = UserDefaults.standard.object(forKey: CommonConfig.Settings.sound_volume)
		userSettings["vibration"] = UserDefaults.standard.object(forKey: CommonConfig.Settings.vibration)
		userSettings["noti-types"] = UIApplication.shared.currentUserNotificationSettings?.types.rawValue
		
		if tag == 1 { NSLog("--> \(TAG) | build User Config Info [\(tag)]: \(userSettings)") }
		
		return userSettings
	}
	
	public static func buildBaseRequestBody(_ tag: String, _ errors: inout [String: Any], _ suppressError: Bool) throws -> [String: Any] {
		let app = buildAppInfo(tag, &errors)
		let users = try buildUsersInfo(tag, &errors, suppressError)
		let device = try buildDeviceInfo(tag, &errors, suppressError)
		let system = buildSystemInfo(tag, &errors)
		
		var jsonObj: [String: Any] = [
			"tag": tag,
			"app": app,
			"users": users,
			"device": device,
			"system": system
		]
#if DEBUG
		jsonObj["env"] = "DEBUG"
#endif
		
		return jsonObj
	}
	
	public static func getConfig(_ tag: String, data: [String: Any?]?, completion: @escaping (Error?, [String: Any]?) -> Void) {
		do {
			var errors: [String: Any] = [:]
			
			var jsonObj = try buildBaseRequestBody("\(tag)|cfg", &errors, false)
			
			jsonObj["data"] = data
			jsonObj["process"] = buildProcessInfo(1, &errors)
			jsonObj["telephony"] = buildTelephonyInfo(1, &errors)
			jsonObj["connectivity"] = buildConnectivityInfo(1, &errors)
			jsonObj["audio"] = buildAudioInfo(1, &errors)
			jsonObj["user-settings"] = buildUserConfigInfo(1, &errors)
			jsonObj["errors"] = !errors.isEmpty ? errors as Any : nil
			
			let url = URL(string: "https://xthang.xyz/app/config-api.php")!
			
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("ios", forHTTPHeaderField: "platform")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try JSONSerialization.data(withJSONObject: jsonObj, options: [])
			
			let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
				let stt = (response as? HTTPURLResponse)?.statusCode
				let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
				NSLog("<-- \(TAG) | getting Config [\(tag)]: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
				
				if error != nil {
					let msg = "[get config] [1] Something is wrong"
					Snackbar.e(msg)
					completion(error, nil)
					return
				}
				if let d = data {
					do {
						let dict = try JSONSerialization.jsonObject(with: d, options: []) as! [String: Any]
						NSLog("--  \(TAG) | getting Config [\(tag)]: \(dict["result"] ?? "--") | \(dict["device-uid"] ?? "--")")
						
						if stt != 200 {
							let msg = "[2] [code: \(stt as Any? ?? "")] Getting Config error"
							Snackbar.e(msg)
							completion(error, dict)
							return
						}
						
						if (jsonObj["device"] as! [String: Any?])["uid"] == nil {
							try! KeychainItem.saveUserInKeychain(AppConfig.keychainDeviceIdKey, dict["device-uid"] as! String)
						}
						
						if let deviceCheck = dict["device-check"] as? [String: Any] {
							if deviceCheck["invalid-hardware"] as! Bool {
								completion(NSError(domain: "", code: ERROR.InvalidHardware.rawValue, userInfo: [NSLocalizedDescriptionKey: "The device's hardware does not meet the app's requirement"]), dict)
								return
							}
							if deviceCheck["banned"] as! Bool {
								completion(NSError(domain: "", code: ERROR.BannedDevice.rawValue, userInfo: [NSLocalizedDescriptionKey: "Your device is banned"]), dict)
								return
							}
						}
						if let versionCheck = dict["version-check"] as? [String: Any] {
							if versionCheck["update-required"] as! Bool {
								completion(NSError(domain: "", code: ERROR.UpdateRequired.rawValue, userInfo: [NSLocalizedDescriptionKey: "To continue using the app, please update to newest version"]), dict)
								return
							}
							if versionCheck["update-recommended"] as! Bool {
								completion(NSError(domain: "", code: ERROR.UpdateRecommended.rawValue, userInfo: [NSLocalizedDescriptionKey: "New version is available. Do you want to update?"]), dict)
								return
							}
						}
						if let purchasesCheck = dict["purchases-check"] as? [String: Any] {
							// TODO: store purchases on server side
							if let refunded = purchasesCheck["refunded"] as? [[String: Any]] {
								DispatchQueue.main.async {
									Payment.shared.purchasesRefunded(TAG, refunded: refunded)
								}
							}
						}
						
						completion(error, dict)
					} catch {
						NSLog("!-- \(TAG) | getting Config [\(tag)]: decode error: \(error)")
						Snackbar.e("[get config] [2] Something is wrong")
						let idx = dataStr?.firstIndex(of: "{")
						Helper.log("get-cfg", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
						completion(error, nil)
					}
				}
			})
			
			task.resume()
		} catch { /// possible error: KeychainError.unhandledError(25308): errSecInteractionNotAllowed
			NSLog("!-- \(TAG) | cfg [\(tag)] | error: \(error)")
			log(tag, error, data == nil ? nil : "\(data!)")
			completion(error, nil)
			
			// RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.7))
			// fatalError("cfg [\(tag)]: \(error)")
		}
	}
	
	public static func log(_ tag: String, _ e: NSException, _ data: String? = nil) {
		NSLog("!-- \(TAG) | logging Exception: \(tag) | \(e) | data: \(data ?? "--")")
		
		var errors: [String: Any] = [:]
		errors["e-name"] = e.name
		errors["e-reason"] = e.reason
		errors["e-callStackSymbols"] = e.callStackSymbols
		errors["e-data"] = data
		
		logError(tag, errors)
		
		if tag == "uncaught-exception" {
			RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.7))
		}
	}
	
	public static func log(_ tag: String, _ e: Error, _ data: String? = nil) {
		NSLog("!-- \(TAG) | logging Error: \(tag) | \(e) | data: \(data ?? "--")")
		
		var errors: [String: Any] = [:]
		errors["e-name"] = String(describing: type(of: e))
		errors["e-reason"] = "\(e)"
		errors["e-data"] = data
		
		logError(tag, errors)
	}
	
	private static func logError(_ tag: String, _ errors: [String: Any]) {
		var errors = errors
		DispatchQueue.main.async {
			var jsonObj = (try? buildBaseRequestBody(tag, &errors, true)) ?? [:]
			
			jsonObj["errors"] = !errors.isEmpty ? errors as Any : nil
			
			let url = URL(string: "https://xthang.xyz/app/log-api.php")!
			
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("ios", forHTTPHeaderField: "platform")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try? JSONSerialization.data(withJSONObject: jsonObj, options: [])
			
			let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
				let stt = (response as? HTTPURLResponse)?.statusCode
				let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
				NSLog("<-- \(TAG) | log error [\(tag)]: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
			})
			
			task.resume()
		}
	}
	
	public static func sendDeviceTokenToServer(deviceToken: Data) {
		let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		NSLog("--> \(TAG) | sending DeviceToken to xthang: \(token)")
		
		let url = URL(string: "https://xthang.xyz/push-notification/push-subscribe-api.php")!
		let params = ["username": "john", "subscription": token, "subStatus": 1] as Dictionary<String, Any>
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
			let stt = (response as? HTTPURLResponse)?.statusCode
			let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
			NSLog("<-- \(TAG) | sendDeviceTokenToServer: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
			
			if let d = data {
				do {
					let _ = try JSONSerialization.jsonObject(with: d) as! Dictionary<String, AnyObject>
				} catch {
					NSLog("!-- \(TAG) | sendDeviceTokenToServer: Error")
					let idx = dataStr?.firstIndex(of: "{")
					Helper.log("sendDeviceTokenToServer", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
				}
			}
		})
		
		task.resume()
	}
	
	public static func sendFCMTokenToServer(fcmToken: String?) {
		NSLog("--> \(TAG) | sending FCMToken to xthang: \(fcmToken ?? "nil")")
		
		let url = URL(string: "https://xthang.xyz/push-notification/push-subscribe-api.php")!
		let params = ["token": fcmToken ?? ""]
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
			let stt = (response as? HTTPURLResponse)?.statusCode
			let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
			NSLog("<-- \(TAG) | sendFCMTokenToServer: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
			
			if let d = data {
				do {
					let _ = try JSONSerialization.jsonObject(with: d) as! Dictionary<String, AnyObject>
				} catch {
					NSLog("!-- \(TAG) | sendFCMTokenToServer: Error")
					let idx = dataStr?.firstIndex(of: "{")
					Helper.log("sendFCMTokenToServer", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
				}
			}
		})
		
		task.resume()
	}
	
	public static func openSystemSettings(type: PopupAlert.UIType = .type1, title: String) {
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			
			let buttonType: PopupAlert.ButtonType = type == .type1 ? .type1 : .type2
			
			let alert = PopupAlert.initiate(type: type, title: title, message: NSLocalizedString("You need to open Settings to change this", comment: ""), preferredStyle: .alert, buttonType: buttonType)
			if type == .type1 {
				alert.contentView.backgroundColor = .popupBackground
			}
			
			alert.addAction(title: NSLocalizedString("Open", comment: ""), style: .default) {
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return
				}
				
				if UIApplication.shared.canOpenURL(settingsUrl) {
					if #available(iOS 10.0, *) {
						UIApplication.shared.open(settingsUrl, completionHandler: { success in
							NSLog("--  \(TAG) | Settings opened: \(success)") // Prints true
						})
					} else {
						// Fallback on earlier versions
					}
				}
			}
			alert.addAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
			
			topController.view.addSubview(alert)
		}
	}
	
	public static func share(_ tag: String, _ sourceView: UIView, _ sourceRect: CGRect?, viewController: UIViewController?, text: String, image: UIImage) {
		NSLog("--  \(TAG) | share [\(tag)]: ...")
		
		if var controller = viewController ?? UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = controller.presentedViewController {
				controller = presentedViewController
			}
			
			let firstActivityItem = text
			let secondActivityItem : NSURL = NSURL(string: AppConfig.shareURL)!
			
			let activityViewController : UIActivityViewController = UIActivityViewController(
				activityItems: [firstActivityItem, secondActivityItem, image],
				applicationActivities: nil)
			
			// This lines is for the popover you need to show in iPad
			activityViewController.popoverPresentationController?.sourceView = sourceView
			
			// This line remove the arrow of the popover to show in iPad
			// activityViewController.popoverPresentationController?.permittedArrowDirections = .down
			if sourceRect != nil {
				activityViewController.popoverPresentationController?.sourceRect = sourceRect!
			}
			
			if #available(iOS 13.0, *) {
				activityViewController.activityItemsConfiguration = [
					UIActivity.ActivityType.message,
					UIActivity.ActivityType.saveToCameraRoll,
					UIActivity.ActivityType.print,
					UIActivity.ActivityType.addToReadingList,
					UIActivity.ActivityType.postToFacebook,
					UIActivity.ActivityType.postToTwitter,
					UIActivity.ActivityType.postToFlickr,
					UIActivity.ActivityType.postToVimeo,
					UIActivity.ActivityType.postToWeibo,
					UIActivity.ActivityType.postToTencentWeibo,
				] as? UIActivityItemsConfigurationReading
				
				// activityViewController.isModalInPresentation = true
			}
			
			activityViewController.excludedActivityTypes = [
				.assignToContact,
			]
			
			controller.present(activityViewController, animated: true, completion: nil)
		}
	}
	
	public static func showAppRatingDialog(_ tag: String, type: PopupAlert.UIType = .type1) {
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			let view = topController.view!
			
			let buttonType: PopupAlert.ButtonType = type == .type1 ? .type1 : .type2
			
			if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(AppConfig.appleID)?action=write-review") {
				let alert = PopupAlert.initiate(type: type, title: "⭐️", message: NSLocalizedString("Rate us on AppStore", comment: ""), preferredStyle: .alert, buttonType: buttonType)
				if type == .type1 {
					alert.contentView.backgroundColor = .popupBackground
				}
				
				alert.addAction(title: "OK", style: .default) {
					if #available(iOS 10, *) {
						UIApplication.shared.open(url, options: [:], completionHandler: { [weak view] success in
							if !success {
								let alert = PopupAlert.initiate(type: type, title: NSLocalizedString("Something is wrong", comment: ""), message: NSLocalizedString("Failed to open AppStore page", comment: ""), preferredStyle: .alert, buttonType: buttonType)
								alert.addAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
								view?.addSubview(alert)
							}
						})
					} else {
						UIApplication.shared.openURL(url)
					}
				}
				alert.addAction(title: "Cancel", style: .default, handler: nil)
				view.addSubview(alert)
			} else {
				NSLog("!-  \(TAG) | rateApp [\(tag)]: AppStore url not available: \(AppConfig.appleID)")
				let alert = PopupAlert.initiate(type: type, title: NSLocalizedString("Something is wrong", comment: ""), message: NSLocalizedString("Failed to open AppStore page", comment: ""), preferredStyle: .alert, buttonType: buttonType)
				if type == .type1 {
					alert.contentView.backgroundColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
				}
				
				alert.addAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
				view.addSubview(alert)
			}
		}
	}
	
	public static func showAdsRemovalDialog(_ tag: String, type: PopupAlert.UIType = .type1) {
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			let view = topController.view!
			
			let msg: String
			if let _ = AdsStore.shared.adsRemoval {
				msg = NSLocalizedString("Do you want to remove all ads?", comment: "")
			} else {
				msg = NSLocalizedString("[Ads removal is not available. Please try again later!]", comment: "")
			}
			
			let buttonType: PopupAlert.ButtonType = type == .type1 ? .type1 : .type2
			
			let alert = PopupAlert.initiate(type: type, title: NSLocalizedString("Ads removal", comment: ""), message: msg, preferredStyle: .alert, buttonType: buttonType)
			if type == .type1 {
				alert.contentView.backgroundColor = .popupBackground
			}
			alert.buttons.axis = .vertical
			
			if let adsRemoval = AdsStore.shared.adsRemoval {
				alert.addAction(title: NSLocalizedString("OK", comment: "") + " (\(adsRemoval.priceLocale.currencySymbol ?? adsRemoval.priceLocale.currencyCode ?? "🪙")\(adsRemoval.price))", style: .default) {
					_ = Payment.purchase(adsRemoval)
				}
			} else {
				AdsStore.shared.requestProducts(TAG)
			}
			alert.addAction(title: NSLocalizedString("Restore", comment: ""), style: .default) {
				Payment.restorePurchases()
			}
			alert.addAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
			view.addSubview(alert)
		}
	}
	
	public static func initAttributedString(string: String, fontSize: CGFloat) -> NSAttributedString {
		return NSAttributedString(string: string,
								  attributes: [.font: UIFont(name: "Maniac", size: fontSize)!,
											   .strokeColor: UIColor.black,
											   .strokeWidth: -5,
											   .foregroundColor: UIColor.white,
											  ])
	}
	
	public static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
		let ctx = UIGraphicsGetCurrentContext()!
		ctx.saveGState()
		
		let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		ctx.setFillColor(color.cgColor)
		ctx.fillEllipse(in: rect)
		
		ctx.restoreGState()
		let img = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return img
	}
}
