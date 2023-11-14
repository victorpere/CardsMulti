//
//  CardValue.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-13.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation

struct CardDeck: Codable {
    let name: String
    let cards: [Card]
    
    static var standard: CardDeck {
        var cards = [Card]()
        
        for rank in Rank.allCases {
            for suit in Suit.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        
        return CardDeck(name: "standard", cards: cards)
    }
}
