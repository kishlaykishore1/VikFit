//
//  ViewModel.swift
//

import Foundation
import StoreKit

protocol ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool)
    func willStartLongProcess()
    func didFinishLongProcess()
    func showIAPRelatedError(_ error: Error)
    func shouldUpdateUI()
    func didFinishRestoringPurchasesWithZeroProducts()
    func didFinishRestoringPurchasedProducts()
}

class ViewModel {
    // MARK: - Properties
    var delegate: ViewModelDelegate?
    private let model = Model()
    // MARK: - Init
    init() {
    }
    
    // MARK: - Fileprivate Methods
    fileprivate func updatePremiumWithPurchasedProduct(_ product: SKProduct) {
        // Update the proper game data depending on the keyword the
        // product identifier of the give product contains.
        if product.productIdentifier.contains("com.vikfit.week_3") {
            model.premiumData.week_3 = 3
        } else if product.productIdentifier.contains("com.vikfit.week_5") {
            model.premiumData.week_5 = 5
        } else if product.productIdentifier.contains("com.vikfit.3months_3") {
            model.premiumData.months3_3 = 3
        } else if product.productIdentifier.contains("com.vikfit.3months_5") {
            model.premiumData.months3_5 = 5
        } else if product.productIdentifier.contains("com.vikfit.6months_3") {
            model.premiumData.months6_3 = 3
        } else if product.productIdentifier.contains("com.vikfit.6months_5") {
            model.premiumData.months6_5 = 5
        }
        // Store changes.
        _ = model.premiumData.update()
        // Ask UI to be updated and reload the table view.
        delegate?.shouldUpdateUI()
    }
    
    
    // MARK: - Internal Methods
    func getProductForItem(at index: Int) -> SKProduct? {
        // Search for a specific keyword depending on the index value.
        let keyword: String
        
        switch index {
        case 0: keyword = "week_3"
        case 1: keyword = "week_5"
        case 2: keyword = "3months_3"
        case 3: keyword = "3months_5"
        case 4: keyword = "6months_3"
        case 5: keyword = "6months_5"
            
        default: keyword = ""
        }
        // Check if there is a product fetched from App Store containing
        // the keyword matching to the selected item's index.
        guard let product = model.getProduct(containing: keyword) else { return nil }
        return product
    }
    
    // MARK: - Methods To Implement
    func viewDidSetup() {
        delegate?.willStartLongProcess()
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()
                switch result {
                case .success(let products): self.model.products = products
                case .failure(let error): self.delegate?.showIAPRelatedError(error)
                }
            }
        }
    }
    
    func purchase(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            delegate?.willStartLongProcess()
            IAPManager.shared.buy(product: product) { (result) in
                DispatchQueue.main.async {
                    self.delegate?.didFinishLongProcess()
                    switch result {
                    case .success(_): self.updatePremiumWithPurchasedProduct(product)
                    case .failure(let error):
                        self.delegate?.showIAPRelatedError(error)
                        Common.showAlertMessage(message: error.localizedDescription, alertType: .error)
                    }
                }
            }
        }
        return true
    }
    
    func restorePurchases() {
        delegate?.willStartLongProcess()
        IAPManager.shared.restorePurchases { (result) in
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()
                Global.dismissLoadingSpinner()
                switch result {
                case .success(let success):
                    if success {
                        self.delegate?.didFinishRestoringPurchasedProducts()
                    } else {
                        self.delegate?.didFinishRestoringPurchasesWithZeroProducts()
                    }
                case .failure(let error):
                    self.delegate?.showIAPRelatedError(error)
                    Common.showAlertMessage(message: error.localizedDescription, alertType: .error)
                }
            }
        }
    }
}
