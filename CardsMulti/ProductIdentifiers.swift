//
//  ProductIdentifiers.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-25.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

/// Contains information on available and purchased products
class ProductIdentifiers {
    
    // MARK: - Properties
    
    /// List of all available product identifiers. Read from a configuration file
    let identifiers: [String]
    
    /// Stored list of identifiers of purchased products
    @StoredWithDefault (key: "PurchasedIdentifiers", defaultValue: []) private (set) var purchasedIdentifiers: [String]
    
    // MARK: - Initializer
    
    init() {
        if let path = Config.productIdsFilePath, let identifiers = NSArray(contentsOfFile: path) as? [String] {
            self.identifiers = identifiers
        } else {
            self.identifiers = []
        }
    }
    
    // MARK: - Public methods
    
    /// Adds a new identifier to the list of purchased product identifiers.
    /// If the identifier is already in the list, nothing will be added.
    ///
    /// - Parameter identifier: The identifier to add
    func add(purchasedIdentifier identifier: String) {
        if !self.purchasedIdentifiers.contains(identifier) {
            self.purchasedIdentifiers.append(identifier)
        }
    }
}
