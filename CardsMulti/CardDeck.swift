//
//  CardValue.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-13.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation

/// Represents a deck of cards
struct CardDeck: Codable, Hashable {

    /// Array of cards in the deck
    var cards: [Card]
    
    let name: String
    
    let editable: Bool
    
    // MARK: - Initializers
    
    /// Initialize with an array of cards
    init(cards: [Card], name: String, editable: Bool) {
        self.cards = cards
        self.name = name
        self.editable = editable
    }
    
    static var empty: CardDeck {
        CardDeck(cards: [], name: "empty", editable: false)
    }
}
