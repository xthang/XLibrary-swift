//
//  Created by Thang Nguyen on 12/18/21.
//

import UIKit

class LoadingView: UIView {
	
	private let TAG = "\(LoadingView.self)"
	private static let TAG = "\(LoadingView.self)"
	
	private static var keyViewMap: [(key: String, view: LoadingView, autoDismiss: Bool)] = []
	
	private var keys: [(key: String, label: UILabel?, autoDismiss: Bool)] = []
	private let texts = UIStackView()
	
	
	private init() {
		super.init(frame: .null)
		
		layer.zPosition = SceneLayer.disableAllLayer.rawValue
		backgroundColor = .blackTransparent
		translatesAutoresizingMaskIntoConstraints = false
		
		let loader = UIActivityIndicatorView()
		loader.translatesAutoresizingMaskIntoConstraints = false
		loader.startAnimating()
		addSubview(loader)
		
		texts.translatesAutoresizingMaskIntoConstraints = false
		addSubview(texts)
		
		NSLayoutConstraint.activate([
			loader.centerXAnchor.constraint(equalTo: centerXAnchor),
			NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.8, constant: 0),
			texts.centerXAnchor.constraint(equalTo: centerXAnchor),
			texts.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 30)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func didMoveToSuperview() {
		guard let view = superview else { return }
		
		// must set Constraint here, not in willMove()
		// exception 'NSGenericException', reason: 'Unable to activate constraint with anchors <NSLayoutDimension: ...> and <NSLayoutDimension: ...> because they have no common ancestor.  Does the constraint or its anchors reference items in different view hierarchies?  That's illegal.'
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: view.topAnchor),
			bottomAnchor.constraint(equalTo: view.bottomAnchor),
			leftAnchor.constraint(equalTo: view.leftAnchor),
			rightAnchor.constraint(equalTo: view.rightAnchor),
		])
	}
	
	@objc private func hide(_ tag: String, key: String, isAuto: Bool) {
		let klIdx = keys.firstIndex { $0.key == key }!
		
		keys[klIdx].label?.removeFromSuperview()
		keys.remove(at: klIdx)
		
		if keys.count == 0 {
			removeFromSuperview()
		}
	}
	
	static func show(_ tag: String, in window: UIWindow, key: String, text: String? = nil, autoHideAfter autoHideDuration: Double? = nil) {
		print("--  \(TAG) | show [\(tag)]: \(key) | text: \(text ?? "--") | c: \(keyViewMap.count)")
		
		DispatchQueue.main.async {
			var view: LoadingView! = window.subviews.first(where: { $0 is LoadingView }) as? LoadingView
			if view == nil {
				view = LoadingView()
				window.addSubview(view)
			}
			
			keyViewMap.append((key, view, autoHideDuration != nil))
			
			if let text = text {
				let label = UILabel()
				label.accessibilityIdentifier = key
				label.text = text
				label.font = Theme.current.settings.snackbarFont
				label.textColor = .white
				view.texts.addArrangedSubview(label)
				
				view.keys.append((key, label, autoHideDuration != nil))
			} else {
				view.keys.append((key, nil, autoHideDuration != nil))
			}
			
			if autoHideDuration != nil {
				let dismissTimer = Timer(timeInterval: autoHideDuration!, repeats: false) { [weak view] timer in
					print("--  \(TAG) | autoHide [\(tag)]: \(key) | c: \(keyViewMap.count)")
					
					timer.invalidate()
					
					guard let view = view else {
						NSLog("!-  \(TAG) | autoHide [\(tag)]: already hid: \(key)")
						return
					}
					
					if let kvIdx = keyViewMap.firstIndex(where: { $0 == (key, view, true) }) {
						keyViewMap.remove(at: kvIdx)
						view.hide("autoHide", key: key, isAuto: true)
					}
				}
				RunLoop.main.add(dismissTimer, forMode: .common)
			}
		}
	}
	
	static func hide(_ tag: String, key: String) {
		print("--  \(TAG) | hide [\(tag)]: \(key) | c: \(keyViewMap.count)")
		
		// TODO: fix case: this func supposes to hide view A (keyX, autoHide = false) but hides view B (keyX, autoHide = true) instead, then A will never be hide
		if let kvIdx = keyViewMap.firstIndex(where: { $0.key == key }) {
			let v = keyViewMap.remove(at: kvIdx)
			
			DispatchQueue.main.async {
				v.view.hide(tag, key: key, isAuto: false)
			}
		}
	}
}
