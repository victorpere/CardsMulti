//
//  Game.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class Global {
    static func newShuffledDeck(name: String, deck: CardDeck) -> [CardSpriteNode] {
        let shuffledDeck = (GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck.cards) as! [Card]).map {
            CardSpriteNode(card: $0, name: name)
        }
        return shuffledDeck
    }

    static func shuffle(_ deck: inout [CardSpriteNode]) {
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [CardSpriteNode]
    }

    // console log functions

    static func displayCards(_ cards: [CardSpriteNode]) {
        for cardNode in cards {
            print(" \(cardNode.card.symbol) (\(cardNode.zPosition))", terminator:"")
        }
        print()
    }

    static func cardDictionary(for cardNode: CardSpriteNode, cardPosition: CGPoint, cardRotation: CGFloat, faceUp: Bool, playerPosition: Position, width: CGFloat, yOffset: CGFloat, moveToFront: Bool, animate: Bool, velocity: CGVector?) -> NSDictionary {
        let newPositionRelative = CGPoint(x: cardPosition.x / width, y: (cardPosition.y - yOffset) / width)
        let velocityRelative = CGVector(dx: (velocity?.dx ?? 0) / width, dy: (velocity?.dy ?? 0) / width)
        
        var newPositionTransposed = CGPoint()
        var newRotationTransposed = CGFloat()
        var velocityTransposed = CGVector()
        
        switch playerPosition {
        case .bottom :
            newPositionTransposed = newPositionRelative
            newRotationTransposed = cardRotation
            velocityTransposed = velocityRelative
        case .top :
            newPositionTransposed.x = 1 - newPositionRelative.x
            newPositionTransposed.y = 1 - newPositionRelative.y
            newRotationTransposed = cardRotation - CGFloat.pi
            velocityTransposed = CGVector(dx: -velocityRelative.dx, dy: -velocityRelative.dy)
        case .left :
            // UNTESTED
            newPositionTransposed.x = newPositionRelative.y
            newPositionTransposed.y = 1 - newPositionRelative.x
            newRotationTransposed = CGFloat.pi / 2 + cardRotation
            velocityTransposed = CGVector(dx: velocityRelative.dy, dy: -velocityRelative.dx)
        case .right:
            // UNTESTED
            newPositionTransposed.x = 1 - newPositionRelative.y
            newPositionTransposed.y = newPositionRelative.x
            newRotationTransposed = CGFloat.pi / 2 - cardRotation
            velocityTransposed = CGVector(dx: -velocityRelative.dy, dy: velocityRelative.dx)
        default:
            break
        }
        
        let cardDictionary: NSMutableDictionary = [
            "c": cardNode.card.symbol as String,
            "f": faceUp,
            "p": NSCoder.string(for: newPositionTransposed),
            "m": moveToFront,
            "a": animate,
            "r": newRotationTransposed,
            //"v": NSCoder.string(for: velocityTransposed)
            //"zPosition": cardNode.zPosition
        ]
        
        if !velocityTransposed.zero {
            cardDictionary.setValue(NSCoder.string(for: velocityTransposed), forKey: "v")
        }
        
        return cardDictionary
    }
    
    static func cardDictionaryArray(with cardNodes: [CardSpriteNode], playerPosition: Position, width: CGFloat, yOffset: CGFloat, moveToFront: Bool, animate: Bool, velocity: CGVector?) -> [NSDictionary] {
        var cardDictionaryArray = [NSDictionary]()
        for cardNode in cardNodes.sorted(by: { $0.zPosition < $1.zPosition }) {
            let cardDictionary = Global.cardDictionary(for: cardNode, cardPosition: cardNode.position, cardRotation: cardNode.zRotation, faceUp: cardNode.faceUp, playerPosition: playerPosition, width: width, yOffset: yOffset, moveToFront: moveToFront, animate: animate, velocity: velocity)
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
