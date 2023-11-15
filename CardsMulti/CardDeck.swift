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
    
    // MARK: - Initializers
    
    /// Initialize with an array of cards
    private init(cards: [Card]) {
        self.cards = cards
    }
    
    /// Initialize by pack type
    init(pack: Pack) {
        switch pack {
        case .standard:
            self = CardDeck.standard
        case .piquet:
            self = CardDeck.piquet
        }
    }
    
    // MARK: - Static methods
    
    /// Create a standard 52-card deck
    static var standard: CardDeck {
        var cards = [Card]()
        
        for rank in Rank.allCases {
            for suit in Suit.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        
        return CardDeck(cards: cards)
    }
    
    /// Create a 32-card piquet pack
    static var piquet: CardDeck {
        var cards = [Card]()
        
        for rank in Rank.allCases.filter({ rank in return rank.rawValue >= 7 }) {
            for suit in Suit.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        
        return CardDeck(cards: cards)
    }
    
    /// Pack types
    enum Pack: String {
        case standard
        case piquet
    }
}
