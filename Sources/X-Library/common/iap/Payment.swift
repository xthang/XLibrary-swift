//
//  Created by Thang Nguyen on 10/28/21.
//

import StoreKit

/// A structure of messages that will be displayed to users.
struct Messages {
#if os (iOS)
	static let cannotMakePayments = "\(notAuthorized) \(installing)"
#else
	static let cannotMakePayments = "In-App Purchases are not allowed."
#endif
	static let couldNotFind = "Could not find resource file:"
	static let deferred = "Allow the user to continue using your app."
	static let deliverContent = "Deliver content for"
	static let emptyString = ""
	static let error = "Error: "
	static let failed = "failed."
	static let installing = "In-App Purchases may be restricted on your device."
	static let invalidIndexPath = "Invalid selected index path"
	static let noRestorablePurchases = "There are no restorable purchases.\n\(previouslyBought)"
	static let noPurchasesAvailable = "No purchases available."
	static let notAuthorized = "You are not authorized to make payments."
	static let okButton = "OK"
	static let previouslyBought = "Only previously bought non-consumable products and auto-renewable subscriptions can be restored."
	static let productRequestStatus = "Product Request Status"
	static let purchaseOf = "Purchase of"
	static let purchaseStatus = "Purchase Status"
	static let removed = "was removed from the payment queue."
	static let restorable = "All restorable transactions have been processed by the payment queue."
	static let restoreContent = "Restore content for"
	static let status = "Status"
	static let unableToInstantiateAvailableProducts = "Unable to instantiate an AvailableProducts."
	static let unableToInstantiateInvalidProductIds = "Unable to instantiate an InvalidProductIdentifiers."
	static let unableToInstantiateMessages = "Unable to instantiate a MessagesViewController."
	static let unableToInstantiateNavigationController = "Unable to instantiate a navigation controller."
	static let unableToInstantiateProducts = "Unable to instantiate a Products."
	static let unableToInstantiatePurchases = "Unable to instantiate a Purchases."
	static let unableToInstantiateSettings = "Unable to instantiate a Settings."
	static let unknownPaymentTransaction = "Unknown payment transaction case."
	static let unknownDestinationViewController = "Unknown destination view controller."
	static let unknownDetail = "Unknown detail row:"
	static let unknownPurchase = "No selected purchase."
	static let unknownSelectedSegmentIndex = "Unknown selected segment index: "
	static let unknownSelectedViewController = "Unknown selected view controller."
	static let unknownTabBarIndex = "Unknown tab bar index:"
	static let unknownToolbarItem = "Unknown selected toolbar item: "
	static let updateResource = "Update it with your product identifiers to retrieve product information."
	static let useStoreRestore = "Use Store > Restore to restore your previously bought non-consumable products and auto-renewable subscriptions."
	static let viewControllerDoesNotExist = "The main content view controller does not exist."
	static let windowDoesNotExist = "The window does not exist."
}

public class Payment: NSObject {
	
	private static let TAG = "💰"
	private let TAG = "💰"
	
	public static let shared = Payment()
	
	public var purchasedIdentifiers: Set<ProductIdentifier>
	
	
	override init() {
		NSLog("-------  \(TAG)")
		
		if let p = UserDefaults.standard.stringArray(forKey: CommonConfig.Keys.purchased) {
			purchasedIdentifiers = Set(p)
		} else {
			purchasedIdentifiers = []
		}
		
		super.init()
		
		SKPaymentQueue.default().add(self)
	}
	
	public class func purchase(_ product: SKProduct) -> Bool {
		NSLog("--  \(Payment.TAG) | purchase ...: \(product.productIdentifier)")
		
		if !SKPaymentQueue.canMakePayments() {
			NSLog("--  \(Payment.TAG) | purchase: canMakePayments: \(Messages.cannotMakePayments)")
			Snackbar.w(Messages.cannotMakePayments)
			return false
		} else {
			let payment = SKPayment(product: product)
			SKPaymentQueue.default().add(payment)
			return true
		}
	}
	
	public class func restorePurchases() {
		NSLog("--  \(Payment.TAG) | restorePurchases ...")
		
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	public class func verifyReceipt(_ tag: String, productIdentifier: String, type: String, transaction: SKPaymentTransaction, completion: @escaping (Error?, [String: Any]?) -> Void) {
		let state = transaction.transactionState
		
		// Get the receipt if it's available
		if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
		   FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
			let receiptString: String
			do {
				let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
				receiptString = receiptData.base64EncodedString(options: [])
				NSLog("--  \(Payment.TAG) | verify-receipt [\(tag)] [\(type)-\(state.rawValue)] (\(appStoreReceiptURL.path)) -> \(receiptString)")
			} catch {
				NSLog("!-  \(Payment.TAG) | verify-receipt [\(tag)] [\(type)-\(state.rawValue)]: Couldn't read receipt data (\(appStoreReceiptURL.path)) with error: " + error.localizedDescription)
				Snackbar.e("[\(type)-\(state.rawValue)] Couldn't read receipt data")
				completion(error, nil)
				return
			}
			
			do {
				var errors: [String: Any] = [:]
				
				var jsonObj = try Helper.buildBaseRequestBody(tag, &errors, false)
				
				var trans: [String: Any] = [:]
				trans["product-identifier"] = productIdentifier
				trans["transaction-type"] = type
				trans["transaction-identifier"] = transaction.transactionIdentifier
				trans["transaction-date"] = transaction.transactionDate?.formatted(CommonConfig.dateFormat)
				trans["transaction-state"] = state.rawValue
				
				jsonObj["transaction"] = trans
				jsonObj["receipt"] = receiptString
				
				jsonObj["errors"] = !errors.isEmpty ? errors as Any : nil
				
				let url = URL(string: "https://xthang.xyz/app/verify-receipt-apple.php")!
				
				var request = URLRequest(url: url)
				request.httpMethod = "POST"
				request.setValue("ios", forHTTPHeaderField: "platform")
				request.addValue("application/json", forHTTPHeaderField: "Content-Type")
				request.httpBody = try JSONSerialization.data(withJSONObject: jsonObj, options: [])
				
				let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
					let stt = (response as? HTTPURLResponse)?.statusCode
					let dataStr = data != nil ? String(decoding: data!, as: UTF8.self) : nil
					NSLog("<-- \(TAG) | verify-receipt [\(tag)] [\(type)-\(state.rawValue)]: rép: \(stt as Any? ?? "--") | error: \(error?.localizedDescription ?? "--") | data: \(dataStr ?? "--")")
					
					if error != nil {
						let msg = "[1] Verifying receipt [\(type)-\(state.rawValue)]: Something is wrong"
						Snackbar.e(msg)
						completion(error, nil)
						return
					}
					if let d = data {
						do {
							let dict = try JSONSerialization.jsonObject(with: d, options: []) as! [String: Any]
							NSLog("--  \(TAG) | verify-receipt [\(tag)] [\(type)-\(state.rawValue)]: \(dict["result"] ?? "--") | \(dict["device-uid"] ?? "--") | \(dict["update-required"] ?? "--") | \(dict["update-recommended"] ?? "--")")
							
							if stt != 200 {
								let msg = "[code: \(stt as Any? ?? "")] Verifing receipt [\(type)-\(state.rawValue)]: error"
								Snackbar.e(msg)
								completion(error, nil)
								return
							}
							
							completion(nil, dict)
						} catch {
							NSLog("!-- \(TAG) | verify-receipt [\(tag)] [\(type)-\(state.rawValue)]: decode error: \(error)")
							Snackbar.e("[2] Verifying receipt [\(type)-\(state.rawValue)]: Something is wrong")
							let idx = dataStr?.firstIndex(of: "{")
							Helper.log("verify-receipt", error, idx != nil ? String(dataStr![..<idx!]) + "|......" : dataStr)
							completion(error, nil)
						}
					}
				})
				
				task.resume()
			} catch {
				NSLog("!-  \(Payment.TAG) | verify-receipt [\(tag)] [\(type)-\(state.rawValue)]: Verify receipt with error: " + error.localizedDescription)
				Snackbar.e("Verify receipt [\(type)-\(state.rawValue)]: error")
				completion(error, nil)
			}
		} else {
			completion(NSError(domain: "", code: ERROR.NoReceiptFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "No receipt"]), nil)
		}
	}
	
	public func purchasesRefunded(_ tag: String, refunded: [[String: Any]]) {
		NSLog("--  \(TAG) | purchasesRefunded [\(tag)]: \(refunded)")
		
		refunded.forEach { purchasedIdentifiers.remove($0["product-identifier"] as! String) }
		UserDefaults.standard.set(Array(self.purchasedIdentifiers), forKey: CommonConfig.Keys.purchased)
		NotificationCenter.default.post(name: .IAPRefunded, object: refunded)
	}
}

extension Payment: SKPaymentTransactionObserver {
	
	public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		if transactions.isEmpty { NSLog("--  \(TAG) | paymentQueue - updatedTransactions: \(transactions)") }
		
		for transaction in transactions {
			NSLog("--  \(TAG) | paymentQueue - transaction: \(transaction.transactionState.rawValue) - \(transaction.transactionIdentifier as Any? ?? "--") - \(transaction.transactionDate as Any? ?? "--") - \(transaction.error as Any? ?? "--")")
			switch (transaction.transactionState) {
				case .purchasing:
					break
				case .purchased:
					updatePurchasedIdentifiers(identifier: transaction.payment.productIdentifier, type: "purchase", transaction: transaction)
					SKPaymentQueue.default().finishTransaction(transaction)
				case .failed:
					if let error = transaction.error as? SKError, error.code != .paymentCancelled {
						Snackbar.e("Payment: " + error.localizedDescription)
					}
					
					SKPaymentQueue.default().finishTransaction(transaction)
				case .restored:
					guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
					
					updatePurchasedIdentifiers(identifier: productIdentifier, type: "restore", transaction: transaction)
					SKPaymentQueue.default().finishTransaction(transaction)
				case .deferred:
					break
				@unknown default:
					break
			}
		}
	}
	
	/// Logs all transactions that have been removed from the payment queue.
	public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			NSLog("--  \(TAG) | \(transaction.payment.productIdentifier) \(Messages.removed)")
		}
	}
	
	public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		NSLog("--  \(TAG) | paymentQueueRestoreCompletedTransactionsFinished")
	}
	
	public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
		NSLog("--  \(TAG) | paymentQueue - restoreCompletedTransactionsFailedWithError: \(error)")
		
		if let error = error as? SKError, error.code != .paymentCancelled {
			Snackbar.e("Restore: " + error.localizedDescription)
		}
	}
	
	func updatePurchasedIdentifiers(identifier: String, type: String, transaction: SKPaymentTransaction) {
		Payment.verifyReceipt("iap", productIdentifier: identifier, type: type, transaction: transaction) { [weak self] error, data in
			Singletons.instance.paymentSuccessSound.play()
			
			DispatchQueue.main.async {
				Snackbar.s(NSLocalizedString("Transaction is successful", comment: "") + " [\(type)-\(transaction.transactionState.rawValue)]")
				self?.purchasedIdentifiers.insert(identifier)
				if self != nil { UserDefaults.standard.set(Array(self!.purchasedIdentifiers), forKey: CommonConfig.Keys.purchased) }
				NotificationCenter.default.post(name: .IAPPurchased, object: identifier)
			}
		}
	}
}
