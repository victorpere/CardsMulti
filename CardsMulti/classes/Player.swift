//
//  Player.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class Player {
    let xOffset: CGFloat = 20.0
    let yOffset: CGFloat = 5.0
    let playMoveDuration = 0.5
    
    var hand = [CardSpriteNode]()
    var playerNumber: Int
    var numberOfCardsInHand = 6
    var human = false
    
    init(_ playerNumber: Int,_ hand: [CardSpriteNode]) {
        self.hand = hand
        self.playerNumber = playerNumber
    }
    
    func attack(turn: Turn, trump: Card) -> CardSpriteNode? {
        if self.hand.count < 1 {
            return nil
        }
        var attackingCard: CardSpriteNode?
        var playableCards: [CardSpriteNode]
        let cardsInPlay = turn.cardsInPlay()
        if cardsInPlay.count > 0 {
            playableCards = self.hand.filter { $0.includesRank(among: turn.cardsInPlay()) }
        } else {
            playableCards = hand
        }
        if playableCards.count > 0 {
            attackingCard = playableCards.lowestCard(with: trump)
            _ = hand.remove(cardNode: attackingCard!)
        }
        
        return attackingCard
    }
    
    func defend(against attackingCard: CardSpriteNode, trump:Card) -> CardSpriteNode? {
        if self.hand.count < 1 {
            return nil
        }
        var defendingCard: CardSpriteNode?
        let playableCards = self.hand.filter { $0.beats(attackingCard, trump: trump) }
        if playableCards.count > 0 {
            defendingCard = playableCards.lowestCard(with: trump)
            _ = hand.remove(cardNode: defendingCard!)
        }

        return defendingCard
    }
    
    func topUp(deck: inout [CardSpriteNode]) {
        if self.hand.count < numberOfCardsInHand && deck.count > 0 {
            let numberOfCardsToTake = min(deck.count, 6 - self.hand.count)
            for _ in 1...numberOfCardsToTake {
                deck[0].zRotation = 0
                self.hand.append(deck[0])
                deck.remove(at: 0)
            }
        }
    }
}

