//
//  Turn.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class Turn {
    var attacks = [Attack]()
    var finished = false
    var turnNumber: Int
    
    init(turnNumber: Int) {
        self.turnNumber = turnNumber
    }
    
    func cardsInPlay() -> [CardSpriteNode] {
        var cards = [CardSpriteNode]()
        for attack in self.attacks {
            cards.append(attack.attackingCard)
            if let defendingCard = attack.defendingCard  {
                cards.append(defendingCard)
            }
        }
        return cards
    }
    
    func defended() -> Bool {
        for attack in attacks {
            if !attack.defended() {
                return false
            }
        }
        return true
    }
    
    func finishTurn(player: inout Player, discardPile: inout [CardSpriteNode], moveCardsTo: CGPoint) {
        if !finished {
            if self.defended() {
                // turn was defended, move cards to discard pile
                discardPile.append(contentsOf: self.cardsInPlay())
            } else {
                // turn was not defended, player takes the cards
                player.hand.append(contentsOf: self.cardsInPlay())
            }
            
        }
    }
}

