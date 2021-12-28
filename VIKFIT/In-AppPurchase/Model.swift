//
//  Model.swift
//

import Foundation
import StoreKit

class Model {
    struct PremiumData: Codable, SettingsManageable {
        var week_3: Int = 0
        var week_5: Int = 0
        var months3_3: Int = 0
        var months3_5: Int = 0
        var months6_3: Int = 0
        var months6_5: Int = 0
    }
    
    var premiumData = PremiumData()
    var products = [SKProduct]()
    
    init() {
        _ = premiumData.load()
    }
    
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword)}.first
    }
}
