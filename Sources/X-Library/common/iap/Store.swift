//
//  Created by Thang Nguyen on 10/28/21.
//

import StoreKit

public typealias ProductIdentifier = String

public enum StoreError: Error {
	case failedVerification
}

open class BaseStore: NSObject {
	
	private let TAG = "🛒"
	
	public var productIdentifiers: Set<ProductIdentifier>
	
	public var productsRequest: SKProductsRequest?
	public var productsRequestCompletionHandler: ((_ result: Result<[SKProduct], Error>) -> Void)?
	
	
	public init(_ tag: String, productIdentifiers: Set<ProductIdentifier>!) {
		// NSLog("-------  \(TAG) | \(tag)")
		
		self.productIdentifiers = productIdentifiers
		
		super.init()
		
		NotificationCenter.default.addObserver(self, selector: #selector(purchased), name: .IAPPurchased, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(purchasesRefunded), name: .IAPRefunded, object: nil)
		
		requestProducts(TAG)
	}
	
	open func requestProducts(_ tag: String, completion completionHandler: ((_ result: Result<[SKProduct], Error>) -> Void)? = nil) {
		NSLog("--  \(TAG) | requestProducts [\(tag)] ...")
		
		productsRequest?.cancel()
		productsRequestCompletionHandler = completionHandler
		
		productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
		productsRequest!.delegate = self
		productsRequest!.start()
	}
	
	@objc open func purchased(_ notification: NSNotification) {}
	
	@objc open func purchasesRefunded(_ notification: NSNotification) {}
}

extension BaseStore: SKProductsRequestDelegate {
	
	public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		NSLog("--  \(TAG) | Loaded list of products...")
		
		let products = response.products
		let invalidProducts = response.invalidProductIdentifiers
		if !invalidProducts.isEmpty {
			NSLog("--  \(TAG) | invalidProductIdentifiers: \(invalidProducts)")
		}
		productsRequestCompletionHandler?(.success(products))
		productsRequest = nil
		productsRequestCompletionHandler = nil
		
		for p in products {
			var log = "--  \(TAG) | Found product: \(p.contentVersion) - \(p.productIdentifier) - \(p.localizedTitle) - \(p.price) - \(p.priceLocale)"
			if #available(iOS 11.2, *) {
				log += " | \(p.subscriptionPeriod as Any? ?? "--") - \(p.introductoryPrice as Any? ?? "--")"
			}
			if #available(iOS 12.0, *) {
				log += " | \(p.subscriptionGroupIdentifier as Any? ?? "--")"
			}
			if #available(iOS 12.2, *) {
				log += " | \(p.discounts)"
			}
			print(log)
			
			processProduct(p)
		}
	}
	
	public func request(_ request: SKRequest, didFailWithError error: Error) {
		NSLog("--  \(TAG) | Failed to load list of products - Error: \(error.localizedDescription)")
		
		productsRequestCompletionHandler?(.failure(error))
		productsRequest = nil
		productsRequestCompletionHandler = nil
	}
	
	public func requestDidFinish(_ request: SKRequest) {
		print("--  \(TAG) | request did finish")
	}
	
	@objc open func processProduct(_ product: SKProduct) {}
}

public class AdsStore: BaseStore {
	
	private let TAG = "🛒Ads"
	
	public static let shared = AdsStore()
	
	public var adsRemovalID: ProductIdentifier
	var adsRemoval: SKProduct? = nil
	
	init() {
		NSLog("-------  \(TAG)")
		
		let path = Bundle.main.path(forResource: "Products", ofType: "plist")!
		let plist = FileManager.default.contents(atPath: path)! //or Data(contentsOf: url)
		let products = try! PropertyListSerialization.propertyList(from: plist, format: nil) as! [String: Any]
		
		adsRemovalID = products["ads-removal"] as! String
		
		super.init(TAG, productIdentifiers: [adsRemovalID])
	}
	
	public override func processProduct(_ product: SKProduct) {
		if product.productIdentifier == adsRemovalID {
			adsRemoval = product
		} else {
			fatalError("--  \(TAG) | Unknown product")
		}
	}
	
	public override func purchased(_ notification: NSNotification) {
		super.purchased(notification)
		
		if let id = notification.object as? String, id == adsRemovalID {
			NSLog("--  \(TAG) | purchased: \(id)")
			
			// already show noti in Payment
			Snackbar.s(NSLocalizedString("Ads are removed", comment: ""))
			
			NotificationCenter.default.post(name: .AdsStatusChanged, object: false)
		}
	}
	
	public override func purchasesRefunded(_ notification: NSNotification) {
		super.purchasesRefunded(notification)
		
		if let refunded = notification.object as? [[String: Any]], refunded.contains(where: { $0["product-identifier"] as! String == adsRemovalID }) {
			NSLog("--  \(TAG) | purchasesRefunded: \(adsRemovalID)")
			
			NotificationCenter.default.post(name: .AdsStatusChanged, object: true)
		}
	}
}
