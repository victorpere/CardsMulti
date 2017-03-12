//
//  Attack.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

class Attack {
    var attackingCard: CardSpriteNode
    var defendingCard: CardSpriteNode?
    var trump: Card
    
    init(attackingCard: CardSpriteNode, trump: Card) {
        self.attackingCard = attackingCard
        self.trump = trump
    }
    
    func defended() -> Bool {
        if let card = defendingCard?.card {
            return card.beats(attackingCard.card!, trump: trump)
        }
        return false
    }
}
