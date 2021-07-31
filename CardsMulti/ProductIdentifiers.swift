//
//  ProductIdentifiers.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-25.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

/// Contains information on available and purchased products
class ProductIdentifiers: StoredBase {
    
    // MARK: - Properties
    
    let purchasedIdentifiersKey = "PurchasedIdentifiers"
    var identifiers = [String]()
    var purchasedIdentifiers: [String]!
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        
        if let path = Config.productIdsFilePath, let identifiers = NSArray(contentsOfFile: path) as? [String] {
            self.identifiers = identifiers
        }
        
        self.purchasedIdentifiers = self.settingOrDefault(forKey: self.purchasedIdentifiersKey , defaultValue: [String]())
    }
    
    // MARK: - Public methods
    
    func add(purchasedIdentifier identifier: String) {
        if !self.purchasedIdentifiers.contains(identifier) {
            self.purchasedIdentifiers.append(identifier)
            self.setSetting(forKey: self.purchasedIdentifiersKey, toValue: self.purchasedIdentifiers)
        }
    }
}
