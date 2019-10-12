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
    let cardWidthsPerScreen: CGFloat = 6.0
    let cardHeightFullSizePixels: CGFloat = 726.0
    let cardHeightsPerScreen: CGFloat = CGFloat(1334.0 / 145.2) // 181.5)
    let flipDuration = 0.2
    let backImageName = "back"
    
    var cardScale: CGFloat = 0.25
    var popScaleBy: CGFloat = 1.1
    
    var card: Card?
    var frontTexture: SKTexture?
    var backTexture: SKTexture?
    var faceUp = true
    var moving = false
    var selectable = false
    
    var flipToFrontAction: SKAction!
    var flipToBackAction: SKAction!
    var popAction: SKAction!
    
    var moveSound: SKAction!
    
    var shadowNode: SKSpriteNode!
    var shadowFlipAction: SKAction!
    
    // MARK: - Initializers
    
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
        self.backTexture = SKTexture(imageNamed: self.backImageName)
        self.backTexture?.filteringMode = SKTextureFilteringMode.nearest
        super.init(texture: self.frontTexture, color: .clear, size: (self.frontTexture?.size())!)

        self.card = card
        self.name = name
        self.cardScale = self.getScale()
        self.setScale(self.cardScale)
        
        if #available(iOS 10.0, *) {
            self.flipToFrontAction = Actions.getFlipAction(texture: self.frontTexture!, duration: self.flipDuration)
            self.flipToBackAction = Actions.getFlipAction(texture: self.backTexture!, duration: self.flipDuration)
            
            self.shadowFlipAction = Actions.getShadowFlipAction(duration: self.flipDuration)
        } else {
            let flipFirstHalfFlip = SKAction.scaleX(to: 0.0, duration: self.flipDuration)
            let flipSecondHalfFlip = SKAction.scaleX(to: self.cardScale, duration: flipDuration)
            let textureChangeToFront = SKAction.setTexture(self.frontTexture!)
            let textureChangeToBack = SKAction.setTexture(self.backTexture!)
            
            self.flipToFrontAction = SKAction.sequence([flipFirstHalfFlip, textureChangeToFront, flipSecondHalfFlip])
            self.flipToBackAction = SKAction.sequence([flipFirstHalfFlip, textureChangeToBack, flipSecondHalfFlip])
            
            self.shadowFlipAction = SKAction.sequence([flipFirstHalfFlip, flipSecondHalfFlip])
        }
        
        self.popAction = Actions.getPopAction(originalScale: cardScale, scaleBy: popScaleBy, duration: flipDuration)
        self.moveSound = Actions.getCardMoveSound()
        
        self.shadowNode = SKSpriteNode(texture: SKTexture(imageNamed: backImageName))
        self.shadowNode.color = .black
        self.shadowNode.colorBlendFactor = 1.0
        self.shadowNode.alpha = 0.5
        self.shadowNode.setScale(cardScale)
        self.shadowNode.isHidden = true
    }
    
    // MARK: - Private methods
    
    private func getScale() -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds

        //let screenWidthPixels = screenSize.width * 2
        let cardWidthPixels = screenSize.width / cardWidthsPerScreen
        return cardWidthPixels / cardWidthFullSizePixels
        
        //let screenHeightPixels = screenSize.height * 2
        //let cardHeightPixels = screenHeightPixels / cardHeightsPerScreen
        //return cardHeightPixels / cardHeightFullSizePixels
    }
    
    // MARK: - Public methods
    
    func flip(sendPosition: Bool) {
        self.shadowNode.position = self.position
        self.shadowNode.zPosition = self.zPosition - 0.5
        self.shadowNode.isHidden = false
        
        if faceUp {
            self.run(self.flipToBackAction)
        } else {
            self.run(self.flipToFrontAction)
        }
        
        self.shadowNode.run(self.shadowFlipAction) {
            self.shadowNode.isHidden = true
        }
        
        self.delegate!.makeFlipSound()
        faceUp = !faceUp
        if sendPosition {
            self.delegate!.sendPosition(of: [self], moveToFront: true, animate: false)
        }
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
        self.delegate!.sendPosition(of: [self], moveToFront: true, animate: false)
    }
    
    func stopMoving(startSpeed: CGVector) {
        self.moving = true
        
        var currentSpeed = startSpeed
        var linearSpeed = Math.hypotenuse(from: currentSpeed)
        let linearAcceleration = linearSpeed * self.accelerationMultiplier
        let acceleration = Math.acceleration2d(linearAcceleration: linearAcceleration, speed: currentSpeed)
        
        var movements = [SKAction]()
        while linearSpeed > 0 {
            let movement = SKAction.moveBy(x: currentSpeed.dx * CGFloat(self.accelerationTimeInterval), y: currentSpeed.dy * CGFloat(self.accelerationTimeInterval), duration: self.accelerationTimeInterval)
            movements.append(movement)
            currentSpeed.dx -= CGFloat(accelerationTimeInterval) * acceleration.dx
            currentSpeed.dy -= CGFloat(accelerationTimeInterval) * acceleration.dy
            linearSpeed -= accelerationTimeInterval * linearAcceleration
        }
        if movements.count > 0 {
            let movementSequence = SKAction.sequence(movements)
            self.delegate!.makeMoveSound()
            self.run(movementSequence) {
                self.moving = false
                self.delegate!.sendPosition(of: [self], moveToFront: false, animate: false)
            }
        } else {
            self.moving = false
        }
    }
    
    func moveAndFlip(to newPosition: CGPoint, faceUp: Bool, duration: Double, sendPosition: Bool, animateReceiver: Bool = false) {
        self.moving = true
        let movement = SKAction.move(to: newPosition, duration: duration)
        let actionGroup = SKAction.group([movement, self.moveSound])
        self.delegate!.makeMoveSound()
        self.run(actionGroup) {
            if self.faceUp != faceUp {
                self.flip(sendPosition: sendPosition)
            } else if sendPosition {
                self.delegate!.sendPosition(of: [self], moveToFront: true, animate: animateReceiver)
            }
            self.moving = false
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
    
    func pop() {
        self.run(self.popAction)
    }
    
    func getCardsUnder() -> [CardSpriteNode] {
        return self.delegate!.getCards(under: self)
    }
    
    func isOnTopOfPile() -> Bool {
        return self.delegate!.isOnTopOfPile(self);
    }
    
    func bottomLeftCorner() -> CGPoint {
        return CGPoint(x: self.position.x - self.frame.width / 2, y: self.position.y - self.frame.height / 2)
    }
    
    func bottomRightCorner() -> CGPoint {
        return CGPoint(x: self.position.x + self.frame.width / 2, y: self.position.y - self.frame.height / 2 )
    }
    
    func topLeftCorner() -> CGPoint {
        return CGPoint(x: self.position.x - self.frame.width / 2, y: self.position.y + self.frame.height / 2)
    }
    
    func topRightCorner() -> CGPoint {
        return CGPoint(x: self.position.x + self.frame.width / 2, y : self.position.y + self.frame.height / 2)
    }
}


// MARK: - CardSpriteNodeDelegate

protocol CardSpriteNodeDelegate {
    func moveToFront(_ cardNode: CardSpriteNode)
    func sendPosition(of cardNodes: [CardSpriteNode], moveToFront: Bool, animate: Bool)
    func getCards(under card: CardSpriteNode) -> [CardSpriteNode]
    func isOnTopOfPile(_ cardNode: CardSpriteNode) -> Bool
    //func makeHumanPlayerHandSelectable()
    //func play(_ cardNode: CardSpriteNode) -> CGPoint
    func makeMoveSound()
    func makeFlipSound()
}


// MARK: - Array of CardSpriteNode extension

extension Array where Element:CardSpriteNode {

    func move(transformation: CGPoint) {
        for cardNode in self.sorted(by: { $0.zPosition < $1.zPosition }) {
            cardNode.moving = true
            let currentPosition = cardNode.position
            cardNode.position = CGPoint(x: currentPosition.x + transformation.x, y: currentPosition.y + transformation.y)
        }
    }
    
}

