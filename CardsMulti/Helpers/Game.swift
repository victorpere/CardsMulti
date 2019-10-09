//
//  Game.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class Global {
    static func newShuffledDeck(name: String, settings: Settings) -> [CardSpriteNode] {
        var deck = [CardSpriteNode]()
        
        var suitNum = 0
        while let newSuit = Suit(rawValue: suitNum) {
            var rankNum = settings.minRank
            while let newRank = Rank(rawValue: rankNum) {
                if (rankNum <= settings.maxRank && settings.pips) ||
                    (newRank == .jack && settings.jack) ||
                    (newRank == .queen && settings.queen) ||
                    (newRank == .king && settings.king) ||
                    (newRank == .ace && settings.ace) {
                    let card = CardSpriteNode(card: Card(suit: newSuit, rank:newRank), name: name)
                    deck.append(card)
                }
                
                rankNum += 1
            }
            suitNum += 1
        }
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [CardSpriteNode]
        
        return deck
    }

    static func shuffle(_ deck: inout [CardSpriteNode]) {
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [CardSpriteNode]
    }

    /*
    func deal(deck: inout [CardSpriteNode], numberOfPlayers: Int, numberOfCards: Int) -> [Player] {
        var players = [Player]()
        for playerNumber in 1...numberOfPlayers {
            var hand = [CardSpriteNode]()
            for cardNumber in 1...numberOfCards {
                let card = deck[(playerNumber * cardNumber) + ((numberOfPlayers - playerNumber) * (cardNumber - 1)) - 1]
                hand.append(card)
            }
            let player = Player(playerNumber, hand)
            players.append(player)
        }
        deck = Array(deck.suffix(deck.count - (numberOfPlayers * numberOfCards)))
        return players
    }

    func getTrump(deck: inout [CardSpriteNode]) -> CardSpriteNode {
        let trump = deck[deck.count - 1] // deck[0]
        //deck.append(trump)
        //deck.remove(at: 0)
        return trump
    }

    func getFirstPlayer(players: [Player], trump: Card) -> Int {
        var firstPlayer = 0
        var lowestTrump = Rank.ace.rawValue + 1
        for (playerNumber, player) in players.enumerated() {
            for cardNode in player.hand {
                if cardNode.card?.suit == trump.suit && (cardNode.card?.rank.rawValue)! < lowestTrump {
                    lowestTrump = (cardNode.card?.rank.rawValue)!
                    firstPlayer = playerNumber
                }
            }
        }
        return firstPlayer
    }
    */

    // console log functions

    static func displayCards(_ cards: [CardSpriteNode]) {
        for cardNode in cards {
            if let card = cardNode.card {
                print(" \(card.symbol())", terminator:"")
                //print(" \(card.spriteName)", terminator:"")
            }
        }
        print()
    }

    /*
    func displayStatus(_ players: [Player], _ deck: [CardSpriteNode], _ trump: Card, _ discardPile: [CardSpriteNode]) {
        for player in players {
            print("Player \(player.playerNumber)'s hand:", terminator:"")
            displayCards(player.hand)
        }
        
        print("Trump: \(trump.symbol())")
        print("Cards left: \(deck.count)")
        displayCards(deck)
        print("Discarded: \(discardPile.count)")
        displayCards(discardPile)
        print()
    }
    */

    static func cardDictionaryArray(with cardNodes: [CardSpriteNode], position: Position, width: CGFloat, yOffset: CGFloat, moveToFront: Bool, animate: Bool) -> [NSDictionary] {
        var cardDictionaryArray = [NSDictionary]()
        for cardNode in cardNodes.sorted(by: { $0.zPosition < $1.zPosition }) {
            let newPositionRelative = CGPoint(x: cardNode.position.x / width, y: (cardNode.position.y - yOffset) / width)
            var newPositionTransposed = CGPoint()
            
            switch position {
            case .bottom :
                newPositionTransposed = newPositionRelative
            case .top :
                newPositionTransposed.x = 1 - newPositionRelative.x
                newPositionTransposed.y = 1 - newPositionRelative.y
            case .left :
                newPositionTransposed.x = newPositionRelative.y
                newPositionTransposed.y = 1 - newPositionRelative.x
            case .right:
                newPositionTransposed.x = 1 - newPositionRelative.y
                newPositionTransposed.y = newPositionRelative.x
            default:
                break
            }
            
            let cardDictionary: NSDictionary = [
                "c": (cardNode.card?.symbol())! as String,
                "f": cardNode.faceUp,
                "p": NSCoder.string(for: newPositionTransposed),
                "m": moveToFront,
                "a": animate
                //"zPosition": cardNode.zPosition
            ]
            
            cardDictionaryArray.append(cardDictionary)
        }
        
        return cardDictionaryArray
    }
}
