//
//  Card.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

class Card {
    let suit: Suit
    let rank: Rank
    
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
    
    func beats(_ card: Card, trump: Suit) -> Bool {
        if (self.rank.rawValue > card.rank.rawValue && self.suit == card.suit) ||
            (self.suit == trump && card.suit != trump) {
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
    
    func isNextRank(_ direction: UpOrDown, of adjacentSuitRule: SuitRule, to toCard: Card) -> Bool {
        if !adjacentSuitRule.checkRule(card1: self, card2: toCard) {
            return false
        }
        
        return true
    }
    
    enum UpOrDown {
        case up, down
    }
    
    enum SuitRule {
        case sameSuit, differentColour, any
        
        func checkRule(card1: Card, card2: Card) -> Bool {
            switch self {
            case .sameSuit:
                return card1.suit == card2.suit
            case .differentColour:
                return card1.suit.color != card2.suit.color
            case .any:
                return true
            }
        }
    }
}
