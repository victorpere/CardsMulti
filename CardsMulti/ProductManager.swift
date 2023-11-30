//
//  ProductManager.swift
//  CardsMulti
//
//  Created by Victor on 2023-10-28.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation
import StoreKit

class ProductManager: ObservableObject {
    static let instance = ProductManager()
    
    @Published var products = [String: ProductInfo]()
    
    @StoredValue<[String]>(key: "PurchasedIdentifiers") private var purchasedProductIds
    
    private init() {
        StoreObserver.sharedInstance.delegate = self
        StoreManager.sharedInstance.delegate = self
        
        if let path = Config.productIdsFilePath, let identifiers = NSArray(contentsOfFile: path) as? [String] {
            self.products = identifiers.reduce(into: [String: ProductInfo]()) {
                $0[$1] = ProductInfo(id: $1, price: "", purchased: false, purchasing: false)
            }
        }
        
        self.updatePurchased()
    }
    
    // MARK: - Public methods
    
    /// Fetches available products from the store
    func fetchProductInformation() {
        if !StoreObserver.sharedInstance.isAuthorizedForPayments {
            return
        }
        
        if !self.products.keys.isEmpty {
            StoreManager.sharedInstance.startProductRequest(with: Array(self.products.keys))
        }
    }
    
    /// Restores purchased products
    func restorePurchased() {
        StoreObserver.sharedInstance.restore()
    }
    
    ///  Initiate purchase of product 
    func purchase(productId: String) {
        self.products[productId]?.purchasing = true
        StoreObserver.sharedInstance.purchase(productId)
    }
    
    // MARK: - Private methods
    
    fileprivate func updatePurchased() {
        if self.purchasedProductIds != nil {
            for key in self.products.keys {
                if self.purchasedProductIds!.contains(key) {
                    self.products[key]?.purchased = true
                }
            }
        }
    }
}

// MARK: - StoreManagerDelegate

extension ProductManager: StoreManagerDelegate {
    func didReceive(availableProducts: [SKProduct]) {
        self.products = availableProducts.reduce(into: [String: ProductInfo]()) {
            $0[$1.productIdentifier] = ProductInfo(id: $1.productIdentifier, price: $1.formattedPrice, purchased: false, purchasing: false)
        }
        
        self.updatePurchased()
    }
    
    func didReceive(message: String) {
        self.products = [:]
    }
}

// MARK: - StoreObserverDelegate

extension ProductManager: StoreObserverDelegate {
    func didPurchaseOrRestoreProduct(identifier: String) {
        if self.purchasedProductIds != nil {
            if !self.purchasedProductIds!.contains(identifier) {
                self.purchasedProductIds?.append(identifier)
            }
        } else {
            self.purchasedProductIds = [identifier]
        }
        
        self.products[identifier]?.purchasing = false
        self.products[identifier]?.purchased = true
    }
    
    func didFailToPurchaseProduct(identifier: String) {
        // TODO: handle failure to purchase
        
        self.products[identifier]?.purchasing = false
    }
}

struct ProductInfo {
    var id: String
    var price: String
    var purchased: Bool
    var purchasing: Bool
}
