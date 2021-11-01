//
//  Created by Thang Nguyen on 9/18/21.
//

import UIKit

public struct Snackbar {
	
	public enum NotiType {
		case i
		case s
		case w
		case e
	}
	
	public static func initSnackbar(_ msg: String, duration: TTGSnackbarDuration = .long) -> TTGSnackbar {
		let snackbar = TTGSnackbar(message: msg, duration: duration)
		
		snackbar.leftMargin = 20
		snackbar.rightMargin = 20
		snackbar.messageTextAlign = .center
		
		return snackbar
	}
	
	public static func i(_ msg: String) {
		DispatchQueue.main.async {
			let snackbar = initSnackbar(msg)
			
			snackbar.show()
		}
	}
	
	public static func s(_ msg: String) {
		DispatchQueue.main.async {
			let snackbar = initSnackbar(msg)
			
			snackbar.backgroundColor = UIColor(red:0.30, green:0.72, blue:0.53, alpha:1.00)
			snackbar.messageTextColor = UIColor(red:0.22, green:0.29, blue:0.36, alpha:1.00)
			
			snackbar.show()
		}
	}
	
	public static func w(_ msg: String) {
		DispatchQueue.main.async {
			let snackbar = initSnackbar(msg)
			
			snackbar.backgroundColor = .yellow
			
			snackbar.show()
		}
	}
	
	public static func e(_ msg: String) {
		DispatchQueue.main.async {
			let snackbar = initSnackbar(msg)
			
			snackbar.backgroundColor = .systemRed
			snackbar.messageTextColor = .white
			
			snackbar.show()
		}
	}
	
	public static func show(_ msg: String, _ type: NotiType) {
		switch type {
			case .i: i(msg)
			case .s: s(msg)
			case .w: w(msg)
			case .e: e(msg)
		}
	}
}
