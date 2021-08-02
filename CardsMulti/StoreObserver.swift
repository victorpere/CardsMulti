//
//  StoreObserver.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-24.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation
import StoreKit

class StoreObserver: NSObject {
    
    // MARK: - Shared instance
    
    static let sharedInstance = StoreObserver()
    
    // MARK: - Properties
    
    var purchased = [SKPaymentTransaction]()
    var restored = [SKPaymentTransaction]()
    
    weak var delegate: StoreObserverDelegate?
    
    // MARK: - Private properties
    
    fileprivate var hasRestorablePurchases = false
    
    // MARK: - Computed properties
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // MARK: - Initializer
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public methods
    
    func purchase(_ product: SKProduct) {
        print("Start purchase: \(product.productIdentifier)")
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        if !self.restored.isEmpty {
            self.restored.removeAll()
        }
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Private methods
    
    fileprivate func handlePurchased(_ transaction: SKPaymentTransaction) {
        self.purchased.append(transaction)
        
        print("Purchase successful: \(transaction.payment.productIdentifier)")
        DispatchQueue.main.async {
            self.delegate?.didPurchaseOrRestoreProduct(identifier: transaction.payment.productIdentifier)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func handleFailed(_ transaction: SKPaymentTransaction) {
        print("Purchase failed: \(transaction.payment.productIdentifier)")
        
        DispatchQueue.main.async {
            self.delegate?.didFailToPurchaseProduct(identifier: transaction.payment.productIdentifier)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func handleRestored(_ transaction: SKPaymentTransaction) {
        self.hasRestorablePurchases = true
        self.restored.append(transaction)
        
        print("Restore successful: \(transaction.payment.productIdentifier)")
        
        DispatchQueue.main.async {
            self.delegate?.didPurchaseOrRestoreProduct(identifier: transaction.payment.productIdentifier)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
}

// MARK: - SKPaymentTransactionObserver

extension StoreObserver: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                self.handlePurchased(transaction)
            case .failed:
                self.handleFailed(transaction)
            case .restored:
                self.handleRestored(transaction)
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Protocol StoreObserverDelegate

protocol StoreObserverDelegate: AnyObject {
    func didPurchaseOrRestoreProduct(identifier: String)
    func didFailToPurchaseProduct(identifier: String)
    func didReceive(message: String)
}
