//
//  CardValue.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-13.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation

/// Represents a deck of cards
struct CardDeck: Codable {

    /// Array of cards in the deck
    let cards: [Card]
    
    let name: String?
    
    // MARK: - Initializers
    
    /// Initialize with an array of cards
    init(cards: [Card], name: String? = nil) {
        self.cards = cards
        self.name = name
    }
}
