//
//  CardSpriteNode.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class CardSpriteNode : SKSpriteNode {
    var delegate:CardSpriteNodeDelegate! = nil
    
    let accelerationMultiplier = 4.0
    let accelerationTimeInterval = 0.001

    let cardWidthFullSizePixels: CGFloat = 500.0
    let cardWidthsPerScreen: CGFloat = 8.0
    let cardHeightFullSizePixels: CGFloat = 726.0
    let cardHeightsPerScreen: CGFloat = CGFloat(1334.0 / 145.2) // 181.5)
    let flipDuration = 0.2
    let backImageName = "back"

    var cardScale: CGFloat = 0.25
    
    var card: Card?
    var frontTexture: SKTexture?
    var backTexture: SKTexture?
    var faceUp = true
    var moving = false
    var selectable = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 0, height: 0))
        self.cardScale = self.getScale()
        self.setScale(cardScale)
    }
    
    init(card: Card, name: String) {
        self.frontTexture = SKTexture(imageNamed: card.spriteName)
        self.frontTexture?.filteringMode = SKTextureFilteringMode.nearest
        self.backTexture = SKTexture(imageNamed: backImageName)
        self.backTexture?.filteringMode = SKTextureFilteringMode.nearest
        super.init(texture: self.frontTexture, color: .clear, size: (self.frontTexture?.size())!)

        self.card = card
        self.name = name
        self.cardScale = self.getScale()
        self.setScale(cardScale)
    }
    
    func getScale() -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds

        let screenWidthPixels = screenSize.width * 2
        let cardWidthPixels = screenWidthPixels / cardWidthsPerScreen
        return cardWidthPixels / cardWidthFullSizePixels
        
        //let screenHeightPixels = screenSize.height * 2
        //let cardHeightPixels = screenHeightPixels / cardHeightsPerScreen
        //return cardHeightPixels / cardHeightFullSizePixels
    }
    
    func flip(sendPosition: Bool) {
        let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: flipDuration)
        let secondHalfFlip = SKAction.scaleX(to: cardScale, duration: flipDuration)
        
        setScale(cardScale)
        if faceUp {
            run(firstHalfFlip) {
                self.texture = self.backTexture
                self.run(secondHalfFlip) {
                    if sendPosition {
                        self.delegate!.sendPosition(of: [self])
                    }
                }
            }
        } else {
            run(firstHalfFlip) {
                self.texture = self.frontTexture
                self.run(secondHalfFlip) {
                    if sendPosition {
                        self.delegate!.sendPosition(of: [self])
                    }
                }
            }
        }
        faceUp = !faceUp
    }
    
    func flip(faceUp: Bool, sendPosition: Bool) {
        if self.faceUp != faceUp {
            self.flip(sendPosition: sendPosition)
        }        
    }
    
    func move(transformation: CGPoint) {
        self.moving = true
        let currentPosition = self.position
        self.position = CGPoint(x: currentPosition.x + transformation.x, y: currentPosition.y + transformation.y)
        self.delegate!.sendPosition(of: [self])
    }
    
    func stopMoving(startSpeed: CGVector) {
        self.moving = true
        
        var currentSpeed = startSpeed
        var linearSpeed = hypotenuse(from: currentSpeed)
        let linearAcceleration = linearSpeed * accelerationMultiplier
        let acceleration = acceleration2d(linearAcceleration: linearAcceleration, speed: currentSpeed)
        
        //print("speed: \(linearSpeed)")
        //print("acceleration: \(linearAcceleration)")
        
        var movements = [SKAction]()
        while linearSpeed > 0 {
            let movement = SKAction.moveBy(x: currentSpeed.dx * CGFloat(accelerationTimeInterval), y: currentSpeed.dy * CGFloat(accelerationTimeInterval), duration: accelerationTimeInterval)
            movements.append(movement)
            currentSpeed.dx -= CGFloat(accelerationTimeInterval) * acceleration.dx
            currentSpeed.dy -= CGFloat(accelerationTimeInterval) * acceleration.dy
            linearSpeed -= accelerationTimeInterval * linearAcceleration
        }
        if movements.count > 0 {
            let movementSequence = SKAction.sequence(movements)
            self.run(movementSequence) {
                self.moving = false
                //self.delegate.makeHumanPlayerHandSelectable()
                self.delegate!.sendPosition(of: [self])
            }
        } else {
            self.moving = false
            //self.delegate.makeHumanPlayerHandSelectable()
        }
    }
    
    func moveAndFlip(to newPosition: CGPoint, faceUp: Bool, duration: Double) {
        self.moving = true
        let movement = SKAction.move(to: newPosition, duration: duration)
        self.run(movement) {
            if self.faceUp != faceUp {
                self.flip(sendPosition: true)
            } else {
                self.delegate!.sendPosition(of: [self])
            }
            self.moving = false
            //print(self.card?.symbol()," moveAndFlip ", newPosition, self.position)
        }
    }
    
    func includesRank(among cardNodes: [CardSpriteNode]) -> Bool {
        let filtered = cardNodes.filter { $0.card?.rank.rawValue == self.card?.rank.rawValue }
        if filtered.count > 0 {
            return true
        }
        return false
    }
    
    func includesCard(among cardNodes: [CardSpriteNode]) -> Bool {
        let filtered = cardNodes.filter { $0.card?.rank == self.card?.rank && $0.card?.suit == self.card?.suit }
        if filtered.count > 0 {
            return true
        }
        return false
    }
    
    func beats(_ cardNode: CardSpriteNode, trump: Card) -> Bool {
        if ((self.card?.rank.rawValue)! > (cardNode.card?.rank.rawValue)! && (self.card?.suit)! == cardNode.card?.suit) ||
            (self.card?.suit == trump.suit && cardNode.card?.suit != trump.suit) {
            return true
        }
        return false
    }
    
    func moveToFront() {
        delegate!.moveToFront(self)
    }
    
    func getCardsUnder() -> [CardSpriteNode] {
        return self.delegate!.getCards(under: self)
    }
    /*
    func play() -> CGPoint {
        return delegate!.play(self)
    }
    */
}


// CardSpriteNodeDelegate

protocol CardSpriteNodeDelegate {
    func moveToFront(_ cardNode: CardSpriteNode)
    func sendPosition(of cardNodes: [CardSpriteNode])
    func getCards(under card: CardSpriteNode) -> [CardSpriteNode]
    //func makeHumanPlayerHandSelectable()
    //func play(_ cardNode: CardSpriteNode) -> CGPoint
}


// Array of CardSpriteNode extension

extension Array where Element:CardSpriteNode {

    func move(transformation: CGPoint) {
        for cardNode in self {
            cardNode.moving = true
            let currentPosition = cardNode.position
            cardNode.position = CGPoint(x: currentPosition.x + transformation.x, y: currentPosition.y + transformation.y)
        }
    }
    
}
