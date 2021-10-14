//
//  Created by Thang Nguyen on 6/29/21.
//

import UIKit
import SystemConfiguration
import AdSupport
import CoreTelephony
import AVFoundation

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
	
	private static func buildUsersInfo(_ tag: String, _ err: inout [String: Any], _ suppressError: Bool) throws -> [String: Any] {
		var data: [String: Any] = [:]	// why 'Any' ?: in case a value is nil, the value is set to null
		
		do {
			let xUserID = try KeychainItem.currentUserIdentifier
			data["ids"] = xUserID != nil ? [ xUserID ] : nil
			data["current-id"] = xUserID
		} catch {
			if !suppressError { throw error }
			else { err["user-info"] = "[\(tag)] \(error)" }
		}
		
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
		
		if tag == "cfg" { NSLog("--> \(TAG) | build Device Info [\(tag)]: \(device)") }
		
		return device
	}
	
	public static func buildSystemInfo(_ tag: Int, _ err: inout [String: Any]) -> [String: Any] {
		var data: [String: Any] = [:]
		
		data["locale"] = Locale.current.identifier
		data["timeZone"] = TimeZone.current.identifier
		
		var jb: [String: Any] = [:]
		jb["hasCydiaInstalled"] = JailBrakeHelper.hasCydiaInstalled()
		jb["isContainsSuspiciousApps"] = JailBrakeHelper.isContainsSuspiciousApps()
		jb["isSuspiciousSystemPathsExists"] = JailBrakeHelper.isSuspiciousSystemPathsExists()
		jb["canEditSystemFiles"] = JailBrakeHelper.canEditSystemFiles()
		
		data["jailbreak"] = jb
		
		if tag == 1 { NSLog("--> \(TAG) | build System Info [\(tag)]: \(data)") }
		
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
		userSettings["noti-types"] = try? UIApplication.shared.currentUserNotificationSettings?.types.rawValue
		
		if tag == 1 { NSLog("--> \(TAG) | build User Config Info [\(tag)]: \(userSettings)") }
		
		return userSettings
	}
	
	public static func getConfig(completion: @escaping (Error?, [String: Any]?) -> Void) {
		do {
			var errors: [String: Any] = [:]
			let app = buildAppInfo("cfg", &errors)
			let users = try buildUsersInfo("cfg", &errors, false)
			let device = try buildDeviceInfo("cfg", &errors, false)
			let system = buildSystemInfo(1, &errors)
			let process = buildProcessInfo(1, &errors)
			let telephony = buildTelephonyInfo(1, &errors)
			let connectivity = buildConnectivityInfo(1, &errors)
			let audio = buildAudioInfo(1, &errors)
			let userSettings = buildUserConfigInfo(1, &errors)
			
			let url = URL(string: "https://xthang.xyz/app/config-api.php")!
			
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("ios", forHTTPHeaderField: "platform")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try? JSONSerialization.data(withJSONObject: [
				"tag": 1,
				"app": app,
				"users": users,
				"device": device,
				"system": system,
				"process": process,
				"telephony": telephony,
				"connectivity": connectivity,
				"audio": audio,
				"user-settings": userSettings,
				"errors": !errors.isEmpty ? errors as Any : nil
			], options: [])
			
			let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
				let stt = (response as? HTTPURLResponse)?.statusCode
				let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
				NSLog("<-- \(TAG) | getting Config: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
				
				if error != nil {
					let msg = "[get config] [1] Something is wrong"
					Snackbar.e(msg)
					completion(error, nil)
					return
				}
				if let d = data {
					do {
						let dict = try JSONSerialization.jsonObject(with: d, options: []) as! [String: Any]
						NSLog("--  \(TAG) | getting Config: \(dict["result"] ?? "--") | \(dict["device-uid"] ?? "--") | \(dict["update-required"] ?? "--") | \(dict["update-recommended"] ?? "--")")
						
						if stt != 200 {
							let msg = "[2] [\(stt as Any? ?? "")] Getting Config error"
							Snackbar.e(msg)
							completion(error, dict)
							return
						}
						
						if device["uid"] == nil {
							try! KeychainItem.saveUserInKeychain(AppConfig.keychainDeviceIdKey, dict["device-uid"] as! String)
						}
						completion(error, dict)
					} catch {
						NSLog("!-- \(TAG) | getting Config: decode error: \(error)")
						Snackbar.e("[get config] [2] Something is wrong")
						let idx = dataStr?.firstIndex(of: "{")
						Helper.log("get-cfg", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
						completion(error, nil)
					}
				}
			})
			
			task.resume()
		} catch {
			NSLog("!-- \(TAG) | cfg | error: \(error)")
			log("cfg", error)
			completion(error, nil)
			fatalError("cfg: \(error)")
		}
	}
	
	public static func log(_ tag: String, _ e: NSException, _ data: String? = nil) {
		NSLog("!-- \(TAG) | logging Exception: \(tag) | \(e) | data: \(data ?? "--")")
		
		var errors: [String: Any] = [:]
		errors["e-name"] = e.name
		errors["e-reason"] = e.reason
		errors["e-callStackSymbols"] = e.callStackSymbols
		errors["e-data"] = data
		
		logError(tag, &errors)
		
		if tag == "uncaught-exception" {
			RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 1))
		}
	}
	
	public static func log(_ tag: String, _ e: Error, _ data: String? = nil) {
		NSLog("!-- \(TAG) | logging Error: \(tag) | \(e) | data: \(data ?? "--")")
		
		var errors: [String: Any] = [:]
		errors["e-name"] = String(describing: type(of: e))
		errors["e-reason"] = "\(e)"
		errors["e-data"] = data
		
		logError(tag, &errors)
	}
	
	private static func logError(_ tag: String, _ errors: inout [String: Any]) {
		let app: [String: Any] = buildAppInfo(tag, &errors)
		let users: [String: Any]? = try? buildUsersInfo(tag, &errors, true)
		let device: [String: Any]? = try? buildDeviceInfo(tag, &errors, true)
		
		let url = URL(string: "https://xthang.xyz/app/log-api.php")!
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("ios", forHTTPHeaderField: "platform")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: [
			"tag": tag,
			"app": app,
			"users": users,
			"device": device,
			"errors": !errors.isEmpty ? errors : nil
		], options: [])
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
			let stt = (response as? HTTPURLResponse)?.statusCode
			let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
			NSLog("<-- \(TAG) | \(tag) | log error: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
		})
		
		task.resume()
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
	
	public static func openSystemSettings(title: String) {
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			
			let alert = PopupAlert.initiate(title: title, message: NSLocalizedString("You need to open Settings to change this", comment: ""), preferredStyle: .alert)
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
