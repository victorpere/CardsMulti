//
//  Card.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

struct Card: Codable, Hashable, Equatable {
    let suit: Suit
    let rank: Rank
    
    static var allCards: [Card] {
        var cards: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        return cards
    }
    
    init(suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
    }
    
    // MARK: - decode/encode
    
    private enum CodingKeys: String, CodingKey {
        case suit
        case rank
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.suit = try values.decode(Suit.self, forKey: .suit)
        self.rank = try values.decode(Rank.self, forKey: .rank)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.suit, forKey: .suit)
        try container.encode(self.rank, forKey: .rank)
    }
    
    // MARK: - Computed properties
    
    /// returns a unicode character representing the card
    var unicode: String {
        let codestr = "\(self.suit.unicode)\(self.rank.unicode)"
        if let code = Int(codestr, radix: 16) {
            if let unicode = UnicodeScalar(code) {
                return "\(unicode)"
            }
        }
        
        return "?"
    }
    
    var spriteName: String {
        get {
            return self.rank.name + "_of_" + String(describing: self.suit)
        }
    }
    
    var symbol: String {
        return (self.suit.symbol + self.rank.symbol)
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
