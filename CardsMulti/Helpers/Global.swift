//
//  Game.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class Global {
    static func newShuffledDeck(name: String, settings: StoredSettings) -> [CardSpriteNode] {
        var deck = [CardSpriteNode]()
        
        var suitNum = 0
        while let newSuit = Suit(rawValue: suitNum) {
            var rankNum = settings.minRank
            while let newRank = Rank(rawValue: rankNum) {
                if (rankNum <= settings.maxRank && settings.pipsEnabled) ||
                    (newRank == .jack && settings.jacksEnabled) ||
                    (newRank == .queen && settings.queensEnabled) ||
                    (newRank == .king && settings.kingsEnabled) ||
                    (newRank == .ace && settings.acesEnabled) {
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
                print(" \(card.symbol) (\(cardNode.zPosition))", terminator:"")
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

    static func cardDictionary(for cardNode: CardSpriteNode, cardPosition: CGPoint, cardRotation: CGFloat, faceUp: Bool, playerPosition: Position, width: CGFloat, yOffset: CGFloat, moveToFront: Bool, animate: Bool) -> NSDictionary {
        let newPositionRelative = CGPoint(x: cardPosition.x / width, y: (cardPosition.y - yOffset) / width)
        var newPositionTransposed = CGPoint()
        var newRotationTransposed = CGFloat()
        
        switch playerPosition {
        case .bottom :
            newPositionTransposed = newPositionRelative
            newRotationTransposed = cardRotation
        case .top :
            newPositionTransposed.x = 1 - newPositionRelative.x
            newPositionTransposed.y = 1 - newPositionRelative.y
            newRotationTransposed = cardRotation - CGFloat.pi
        case .left :
            // UNTESTED
            newPositionTransposed.x = newPositionRelative.y
            newPositionTransposed.y = 1 - newPositionRelative.x
            newRotationTransposed = CGFloat.pi / 2 + cardRotation
        case .right:
            // UNTESTED
            newPositionTransposed.x = 1 - newPositionRelative.y
            newPositionTransposed.y = newPositionRelative.x
            newRotationTransposed = CGFloat.pi / 2 - cardRotation
        default:
            break
        }
        
        let cardDictionary: NSDictionary = [
            "c": (cardNode.card?.symbol)! as String,
            "f": faceUp,
            "p": NSCoder.string(for: newPositionTransposed),
            "m": moveToFront,
            "a": animate,
            "r": newRotationTransposed
            //"zPosition": cardNode.zPosition
        ]
        
        return cardDictionary
    }
    
    static func cardDictionaryArray(with cardNodes: [CardSpriteNode], playerPosition: Position, width: CGFloat, yOffset: CGFloat, moveToFront: Bool, animate: Bool) -> [NSDictionary] {
        var cardDictionaryArray = [NSDictionary]()
        for cardNode in cardNodes.sorted(by: { $0.zPosition < $1.zPosition }) {
            let cardDictionary = Global.cardDictionary(for: cardNode, cardPosition: cardNode.position, cardRotation: cardNode.zRotation, faceUp: cardNode.faceUp, playerPosition: playerPosition, width: width, yOffset: yOffset, moveToFront: moveToFront, animate: animate)
            cardDictionaryArray.append(cardDictionary)
        }
        
        return cardDictionaryArray
    }
    
    /**
     Builds an app link URL for the specified method and parameters
     
     - returns app link URL
     */
    static func appLinkUrl(method: String, params: [URLQueryItem]) -> String? {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = Config.appLinksDomain
        components.path = "/\(method)"
        components.queryItems = params
        
        let url = components.url
        return url?.absoluteString
    }
}
