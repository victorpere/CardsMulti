//
//  StoreManager.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-24.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation
import StoreKit

class StoreManager: NSObject {
    
    // MARK: - Shared instance
    
    static let sharedInstance = StoreManager()
    
    // MARK: - Private properties
    
    fileprivate var availableProducts = [SKProduct]()
    fileprivate var invalidProductIdentifiers = [String]()
    
    fileprivate var productRequest: SKProductsRequest!
    
    // MARK: - Properties
    
    weak var delegate: StoreManagerDelegate?
    
    // MARK: - Initializer
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public methods
    
    func startProductRequest(with identifiers: [String]) {
        print("startProductRequest: \(identifiers.count) identifier(s)")
        let productIdentifiers = Set(identifiers)
        
        self.productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        self.productRequest.delegate = self
        self.productRequest.start()
    }
    
}

// MARK: - Extension SKProductsRequestDelegate

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Received available products: \(response.products.count)")
        if !response.products.isEmpty {
            self.availableProducts = response.products
        }
        
        if !response.invalidProductIdentifiers.isEmpty {
            self.invalidProductIdentifiers = response.invalidProductIdentifiers
        }
        
        if !self.availableProducts.isEmpty {
            DispatchQueue.main.async {
                self.delegate?.didReceive(availableProducts: self.availableProducts)
            }
        }
    }
}

// MARK: - Extension SKRequestDelegate

extension StoreManager: SKRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("SKRequest error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.delegate?.didReceive(message: error.localizedDescription)
        }
    }
}

// MARK: - Protocol StoreManagerDelegate

protocol StoreManagerDelegate: AnyObject {
    func didReceive(availableProducts: [SKProduct])
    func didReceive(message: String)
}
