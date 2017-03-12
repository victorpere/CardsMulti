//
//  ArrayOfCards.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

extension Array where Element:Card {
    mutating func remove(card: Card) -> Int {
        for (cardNumber, each) in self.enumerated() {
            if card.rank == each.rank && card.suit == each.suit {
                self.remove(at: cardNumber)
                return cardNumber
            }
        }
        return -1
    }
    
    func lowestCard (with trump: Card) -> Card {
        var lowestCard = self[0]
        for card in self {
            if ((card.rank.rawValue < lowestCard.rank.rawValue && (card.suit != trump.suit || lowestCard.suit == trump.suit)) || (card.suit != trump.suit && lowestCard.suit == trump.suit)) {
                lowestCard = card
            }
        }
        return lowestCard
    }
}

extension Array where Element:CardSpriteNode {
    mutating func remove(cardNode: CardSpriteNode) -> Int {
        for (cardNumber, each) in self.enumerated() {
            if each.card?.rank == cardNode.card?.rank && each.card?.suit == cardNode.card?.suit {
                self.remove(at: cardNumber)
                return cardNumber
            }
        }
        return -1
    }
    
    func lowestCard (with trump: Card) -> CardSpriteNode {
        var lowestCard = self[0]
        for cardNode in self {
            if (((cardNode.card?.rank.rawValue)! < (lowestCard.card?.rank.rawValue)! && (cardNode.card?.suit != trump.suit || lowestCard.card?.suit == trump.suit)) || (cardNode.card?.suit != trump.suit && lowestCard.card?.suit == trump.suit)) {
                lowestCard = cardNode
            }
        }
        return lowestCard
    }
}
