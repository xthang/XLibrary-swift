//
//  Created by Thang Nguyen on 10/28/21.
//

import StoreKit

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
					updatePurchasedIdentifiers(identifier: transaction.payment.productIdentifier)
					SKPaymentQueue.default().finishTransaction(transaction)
				case .failed:
					if let transactionError = transaction.error as NSError?,
					   transactionError.code != SKError.paymentCancelled.rawValue {
						print("--  \(TAG) | Transaction Error: \(transactionError.localizedDescription)")
					}
					
					SKPaymentQueue.default().finishTransaction(transaction)
				case .restored:
					guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
					
					updatePurchasedIdentifiers(identifier: productIdentifier)
					SKPaymentQueue.default().finishTransaction(transaction)
				case .deferred:
					break
				@unknown default:
					break
			}
		}
	}
	
	public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		NSLog("--  \(TAG) | paymentQueueRestoreCompletedTransactionsFinished")
	}
	
	public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
		NSLog("--  \(TAG) | paymentQueue - restoreCompletedTransactionsFailedWithError: \(error)")
	}
	
	func updatePurchasedIdentifiers(identifier: String) {
		purchasedIdentifiers.insert(identifier)
		UserDefaults.standard.set(Array(purchasedIdentifiers), forKey: CommonConfig.Keys.purchased)
		NotificationCenter.default.post(name: .inAppPurchased, object: identifier)
	}
}
