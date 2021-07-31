//
//  SKProduct.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-25.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import StoreKit

extension SKProduct {
    /// - returns: The price of the product formatted in the local currency.
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "\(self.price)"
    }
}
