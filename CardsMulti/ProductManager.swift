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
                $0[$1] = ProductInfo(id: $1, price: "", purchased: false)
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
            $0[$1.productIdentifier] = ProductInfo(id: $1.productIdentifier, price: $1.formattedPrice, purchased: false)
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
    }
    
    func didFailToPurchaseProduct(identifier: String) {
        // TODO: handle failure to purchase
    }
}

struct ProductInfo {
    var id: String
    var price: String
    var purchased: Bool
}
