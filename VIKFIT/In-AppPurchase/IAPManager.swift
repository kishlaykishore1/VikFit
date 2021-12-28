//
//  IAPManager.swift
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
    // MARK: - Custom Types
    
    enum IAPManagerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
    
    // MARK: - Properties
    static let shared = IAPManager()
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
    var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
    var totalRestoredPurchases = 0
    
    // MARK: - Init
    private override init() {
        super.init()
    }
    
    // MARK: - General Methods
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    func getOneSessionPriceFormatted(for price: Double, for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: NSNumber(value: price))
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    // MARK: - Get IAP Products
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
        // Get the product identifiers.
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        // Set self as the its delegate.
        request.delegate = self
        // Make the request.
        request.start()
    }
    
    // MARK: - Purchase Products
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        // Keep the completion handler.
        Global.showLoadingSpinner()
        onBuyProductHandler = handler
    }
    func restorePurchases(withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        onBuyProductHandler = handler
        totalRestoredPurchases = 0
        Global.showLoadingSpinner()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}


// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var latestTransection: SKPaymentTransaction?
        var latestTimeStemp: Double = 0.0
        transactions.forEach { (transaction) in
            if latestTimeStemp < transaction.transactionDate?.timeIntervalSince1970 ?? 0.0 {
                latestTimeStemp = transaction.transactionDate?.timeIntervalSince1970 ?? 0.0
                latestTransection = transaction
            }
        }
        Global.dismissLoadingSpinner()
        guard let transaction = latestTransection else {
            return
        }
        switch transaction.transactionState {
        case .purchased:
            UserDefaults.standard.set(true, forKey: "isPurchased")
            onBuyProductHandler?(.success(true))
            SKPaymentQueue.default().finishTransaction(transaction)
            apiWorkOfDayData(transaction: transaction)
        case .restored:
            UserDefaults.standard.set(true, forKey: "isPurchased")
            apiWorkOfDayData(transaction: transaction, isRestore: true)
            totalRestoredPurchases += 1
            SKPaymentQueue.default().finishTransaction(transaction)
        case .failed:
            if let error = transaction.error as? SKError {
                if error.code != .paymentCancelled {
                    onBuyProductHandler?(.failure(error))
                } else {
                    onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                }
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        case .deferred, .purchasing: break
        @unknown default: break
        }
    }
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            onBuyProductHandler?(.success(true))
        } else {
            Common.showAlertMessage(message: Messages.noPerchase.localized, alertType: .warning)
            onBuyProductHandler?(.success(false))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
            }
        }
    }
    
    func apiWorkOfDayData(transaction: SKPaymentTransaction, isRestore: Bool = false)  {
        var qty = 0
        var timePackage = 0
        switch transaction.payment.productIdentifier {
        case "com.vikfit.week_3":
            qty = 3
            timePackage = 1
            break
        case "com.vikfit.week_5":
            qty = 5
            timePackage = 1
            break
        case "com.vikfit.3months_3":
            qty = 3
            timePackage = 3
            break
        case "com.vikfit.3months_5":
            qty = 5
            timePackage = 3
            break
        case "com.vikfit.6months_3":
            qty = 3
            timePackage = 6
            break
        case "com.vikfit.6months_5":
            qty = 5
            timePackage = 6
            break
        default:
            break
        }
        let userId = UserModel.getUserModel()?.id ?? ""
        let param = ["user_id": userId, "transaction_id": transaction.transactionIdentifier!, "quantity_unlocked": qty, "type": "premium", "time_package": timePackage] as [String : Any]
        if let getRequest = API.WODPLANS.request(method: .post, with: param as [String : Any], forJsonEncoding: true) {
            Global.showLoadingSpinner()
            getRequest.responseJSON { (response) in
                Global.dismissLoadingSpinner()
                API.WODPLANS.validatedResponse(response, completionHandler: { (jsonObject, error) in
                    guard error == nil else {
                        return
                    }
                    let defaults = UserDefaults.standard
                    let dict = ["transaction_id": transaction.transactionIdentifier!, "type": "premium", "productID": transaction.payment.productIdentifier] as [String : Any]
                    defaults.set(dict, forKey: "ReceiptInfo")
                    defaults.synchronize()
                    if isRestore {
                        Common.showAlertMessage(message: Messages.perchaseRestored.localized, alertType: .success)
                    } else {
                        Common.showAlertMessage(message: Messages.thanksPerchase.localized, alertType: .success)
                    }
                    if #available(iOS 13.0, *) {
                        let scene = UIApplication.shared.connectedScenes.first
                        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                            sd.isUserLogin(true)
                        }
                    } else {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.isUserLogin(true)
                    }
                })
            }
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products
        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(products))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
    }
}

// MARK: - IAPManagerError Localized Error Descriptions
extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return Messages.IAPNotFound
        case .noProductsFound: return Messages.IAPNotFound
        case .productRequestFailed: return Messages.IAPUnableToFound
        case .paymentWasCancelled: return Messages.IAPCancel
        }
    }
}
