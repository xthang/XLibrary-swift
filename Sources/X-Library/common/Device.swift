//
//  Created by Thang Nguyen on 9/11/21.
//

import MachO
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import AVFoundation
import UIKit

class Device {
	
	static var isSimulator: Bool { return TARGET_OS_SIMULATOR != 0 }
	
	static func getLocalArch() -> NSString? {
		if let info = NXGetLocalArchInfo() {
			return NSString(utf8String: info.pointee.description)
		} else {
			return nil
		}
	}
	
	static var isJailBroken: Bool {
		get {
			if isSimulator { return false }
			return JailBrakeHelper.hasCydiaInstalled()
			|| JailBrakeHelper.isContainsSuspiciousApps()
			|| JailBrakeHelper.isSuspiciousSystemPathsExists()
			|| JailBrakeHelper.canEditSystemFiles()
		}
	}
	
	static var systemSizeInBytes: Int64? {
		if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
		   let space = systemAttributes[.systemSize] as? NSNumber {
			return space.int64Value
		} else {
			return nil
		}
	}
	
	static var systemFreeSizeInBytes: Int64? {
		if #available(iOS 11.0, *) {
			if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String)
				.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
				.volumeAvailableCapacityForImportantUsage {
				return space
			} else {
				return nil
			}
		} else {
			let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
			if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
			   let freeSize = systemAttributes[.systemFreeSize] as? NSNumber {
				return freeSize.int64Value
			} else {
				return nil
			}
		}
	}
	
	static func bluetoothAudioConnected() -> Bool{
		let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
		for output in outputs {
			if output.portType == AVAudioSession.Port.bluetoothA2DP
				|| output.portType == AVAudioSession.Port.bluetoothHFP
				|| output.portType == AVAudioSession.Port.bluetoothLE {
				return true
			}
		}
		return false
	}
	
	class func isConnectedToNetwork() -> Bool {
		var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
		zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
				SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
			}
		}
		
		var flags = SCNetworkReachabilityFlags(rawValue: 0)
		if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
			return false
		}
		
		/* Only Working for WIFI
		 let isReachable = flags == .reachable
		 let needsConnection = flags == .connectionRequired
		 
		 return isReachable && !needsConnection
		 */
		
		// Working for Cellular and WIFI
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		let ret = (isReachable && !needsConnection)
		
		return ret
	}
	
	static func getAddresses() -> [String: Any]? {
		// Get list of all interfaces on the local machine:
		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddr) == 0 else { return nil }
		guard let firstAddr = ifaddr else { return nil }
		
		var addresses: [String: [String: Any]] = [:]
		
		// For each interface ...
		for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
			let interface = ifptr.pointee
			let flags = Int32(interface.ifa_flags)
			
			// Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
			if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
				let addrFamily = interface.ifa_addr.pointee.sa_family
				if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
					// Check interface name:
					let ifa_name = String(cString: interface.ifa_name)
					if let name = Network(rawValue: ifa_name)?.name {
						// Convert interface address to a human readable string:
						var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
						getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
									&hostname, socklen_t(hostname.count),
									nil, socklen_t(0), NI_NUMERICHOST)
						
						var data: [String: Any] = ["ip": String(cString: hostname)]
						data["name"] = name
						addresses[ifa_name] = data
					}
				}
			}
		}
		freeifaddrs(ifaddr)
		
		return addresses
	}
	
	// require Access Wifi Information entitlement
	static func getCurrentNetworksInfo() -> [[String : AnyObject]]? {
		if let interface = CNCopySupportedInterfaces() {
			var currentNetworksInfo: [[String : AnyObject]] = []
			
			for i in 0..<CFArrayGetCount(interface) {
				let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interface, i)
				let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
				currentNetworksInfo.append(CNCopyCurrentNetworkInfo("\(rec)" as CFString) as! [String : AnyObject])
			}
			
			return currentNetworksInfo
		}
		return nil
	}
}

struct JailBrakeHelper {
	static func hasCydiaInstalled() -> Bool {
		return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
	}
	
	static func isContainsSuspiciousApps() -> Bool {
		for path in suspiciousAppsPathToCheck {
			if FileManager.default.fileExists(atPath: path) {
				return true
			}
		}
		return false
	}
	
	static func isSuspiciousSystemPathsExists() -> Bool {
		for path in suspiciousSystemPathsToCheck {
			if FileManager.default.fileExists(atPath: path) {
				return true
			}
		}
		return false
	}
	
	static func canEditSystemFiles() -> Bool {
		let jailBreakText = "Developer Insider"
		do {
			try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
			return true
		} catch {
			return false
		}
	}
	
	/**
	 Add more paths here to check for jail break
	 */
	private static let suspiciousAppsPathToCheck = [
		"/Applications/Cydia.app",
		"/Applications/blackra1n.app",
		"/Applications/FakeCarrier.app",
		"/Applications/Icy.app",
		"/Applications/IntelliScreen.app",
		"/Applications/MxTube.app",
		"/Applications/RockApp.app",
		"/Applications/SBSettings.app",
		"/Applications/WinterBoard.app"
	]
	
	private static let suspiciousSystemPathsToCheck = [
		"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
		"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
		"/private/var/lib/apt",
		"/private/var/lib/apt/",
		"/private/var/lib/cydia",
		"/private/var/mobile/Library/SBSettings/Themes",
		"/private/var/stash",
		"/private/var/tmp/cydia.log",
		"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
		"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
		"/usr/bin/sshd",
		"/usr/libexec/sftp-server",
		"/usr/sbin/sshd",
		"/etc/apt",
		"/bin/bash",
		"/Library/MobileSubstrate/MobileSubstrate.dylib"
	]
}

enum Network: String {
	case wifi = "en0"
	case en1 = "en1"
	case wired2 = "en2"
	case wired3 = "en3"
	case wired4 = "en4"
	case cellular = "pdp_ip0"
	case cellular1 = "pdp_ip1"
	case cellular2 = "pdp_ip2"
	case cellular3 = "pdp_ip3"
	case cellular4 = "pdp_ip4"
	case ipv4 = "ipv4"
	case ipv6 = "ipv6"
	
	var name: String {
		get { return String(describing: self) }
	}
}
