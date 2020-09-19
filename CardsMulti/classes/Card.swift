//
//  Card.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

class Card {
    var suit: Suit
    var rank: Rank
    
    var spriteName: String {
        get {
            return self.rank.name + "_of_" + String(describing: self.suit)
        }
    }
    
    var symbol: String {
        return (self.suit.symbol + self.rank.symbol)
    }
    
    init(suit: Suit, rank:Rank) {
        self.suit = suit
        self.rank = rank
    }
    
    func beats(_ card: Card, trump: Card) -> Bool {
        if (self.rank.rawValue > card.rank.rawValue && self.suit == card.suit) ||
            (self.suit == trump.suit && card.suit != trump.suit) {
            return true
        }
        return false
    }
    
    func includesRank(among cards: [Card]) -> Bool {
        let filtered = cards.filter { $0.rank.rawValue == self.rank.rawValue }
        if filtered.count > 0 {
            return true
        }
        return false
    }
}
