//
//  CardSpriteNode.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import GameplayKit

class CardSpriteNode : SKSpriteNode {
    
    // MARK: - Properties
    
    var delegate:CardSpriteNodeDelegate! = nil
    
    let accelerationMultiplier = 4.0
    let accelerationTimeInterval = 0.001

    let cardWidthFullSizePixels: CGFloat = 500.0
    let cardWidthsPerScreen: CGFloat = 6.0
    let cardHeightFullSizePixels: CGFloat = 726.0
    //let cardHeightsPerScreen: CGFloat = CGFloat(1334.0 / 145.2) // 181.5)
    let flipDuration = 0.2
    let backImageName = "back"
    let cornerSizeRatio: CGFloat = 0.25  // relative to width
    
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
    
    var debugLabel: SKLabelNode!
    
    // MARK: - Computed properties
    
    var cardWidth: CGFloat { return self.cardWidthFullSizePixels * self.cardScale }
    var cardHeight: CGFloat { return self.cardHeightFullSizePixels * self.cardScale }
    var cardSize: CGSize { return CGSize(width: self.cardWidth, height: self.cardHeight) }
    
    var bottomLeftCorner: CGPoint {
        return CGPoint(x: self.position.x - self.cardSize.width / 2, y: self.position.y - self.cardSize.height / 2)
    }
    
    var bottomRightCorner: CGPoint {
        return CGPoint(x: self.position.x + self.cardSize.width / 2, y: self.position.y - self.cardSize.height / 2 )
    }
    
    var topLeftCorner: CGPoint {
        return CGPoint(x: self.position.x - self.cardSize.width / 2, y: self.position.y + self.cardSize.height / 2)
    }
    
    var topRightCorner: CGPoint {
        return CGPoint(x: self.position.x + self.cardSize.width / 2, y : self.position.y + self.cardSize.height / 2)
    }
    
    var cornerSideSize: CGFloat { return self.cardSize.width * self.cornerSizeRatio }
    var cornerRectSize: CGSize { return CGSize(width: self.cornerSideSize, height: self.cornerSideSize) }
    var bottomLeftRect: CGRect { return CGRect(origin: self.bottomLeftCorner, size: self.cornerRectSize) }
    var bottomRightRect: CGRect { return CGRect(origin: CGPoint(x: self.bottomRightCorner.x - self.cornerSideSize, y: self.bottomRightCorner.y), size: self.cornerRectSize) }
    var topLeftRect: CGRect { return CGRect(origin: CGPoint(x: self.topLeftCorner.x, y: self.topLeftCorner.y - self.cornerSideSize), size: self.cornerRectSize)}
    var topRightRect: CGRect { return CGRect(origin: CGPoint(x: self.topRightCorner.x - self.cornerSideSize, y: self.topRightCorner.y - self.cornerSideSize), size: self.cornerRectSize)}
    
    var cardInfo: NSDictionary {
        get {
            return NSDictionary(dictionary: [
                "name": self.name!,
                "symbol": self.card!.symbol(),
                "suit": self.card!.suit.rawValue,
                "rank": self.card!.rank.rawValue,
                "faceUp": self.faceUp,
                "rotation": self.zRotation,
                "x": self.position.x,
                "y": self.position.y,
                "z": self.zPosition
            ])
        }
    }
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 0, height: 0))
        self.cardScale = self.getScale()
        self.setScale(cardScale)
    }
    
    convenience init(cardInfo: NSDictionary) {
        let name = cardInfo["name"] as! String
        let card = Card(suit: Suit(rawValue: cardInfo["suit"] as! Int)! , rank: Rank(rawValue: cardInfo["rank"] as! Int)!)
        let faceUp = cardInfo["faceUp"] as! Bool
        self.init(card: card, name: name, faceUp: faceUp)
        
        self.position = CGPoint(x: cardInfo["x"] as! CGFloat, y: cardInfo["y"] as! CGFloat)
        self.zPosition = cardInfo["z"] as! CGFloat
        self.zRotation = cardInfo["rotation"] as! CGFloat
    }
    
    init(card: Card, name: String, faceUp: Bool = false) {
        self.frontTexture = SKTexture(imageNamed: card.spriteName)
        self.frontTexture?.filteringMode = SKTextureFilteringMode.nearest
        self.backTexture = SKTexture(imageNamed: self.backImageName)
        self.backTexture?.filteringMode = SKTextureFilteringMode.nearest
        self.faceUp = faceUp
        
        super.init(texture: faceUp ? self.frontTexture : self.backTexture, color: .clear, size: (self.frontTexture?.size())!)

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
        
        self.popAction = Actions.getPopAction(originalScale: self.cardScale, scaleBy: self.popScaleBy, duration: flipDuration)
        self.moveSound = Actions.getCardMoveSound()
        
        self.shadowNode = SKSpriteNode(texture: SKTexture(imageNamed: backImageName))
        self.shadowNode.color = .black
        self.shadowNode.colorBlendFactor = 1.0
        self.shadowNode.alpha = 0.5
        //self.shadowNode.setScale(cardScale)
        self.shadowNode.isHidden = true
        self.shadowNode.zPosition = -0.5
        self.addChild(self.shadowNode)
        
        self.debugLabel = SKLabelNode(text: "")
        if #available(iOS 11.0, *) {
            self.debugLabel.numberOfLines = 0
        } else {
            // Fallback on earlier versions
        }
        #if DEBUG
        self.debugLabel.isHidden = false
        #else
        self.debugLabel.isHidden = true
        #endif
        self.debugLabel.fontColor = UIColor.green
        self.debugLabel.fontSize = 100
        self.debugLabel.fontName = "Helvetica"
        self.debugLabel.position = CGPoint(x: 0, y: self.cardHeightFullSizePixels / 2 + 20)
        self.debugLabel.zPosition = 1000
        self.debugLabel.isUserInteractionEnabled = false
        self.addChild(self.debugLabel)
    }
    
    // MARK: - Private methods
    
    private func getScale() -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let cardWidthsPerScreen = CGFloat(Settings.instance.cardWidthsPerScreen)

        let cardWidthPixels = screenSize.width / cardWidthsPerScreen
        return cardWidthPixels / self.cardWidthFullSizePixels
    }
    
    // MARK: - Public methods
    
    public func updateScale() {
        DispatchQueue.global(qos: .default).async {
            let screenSize: CGRect = UIScreen.main.bounds
            let cardWidthsPerScreen = CGFloat(Settings.instance.cardWidthsPerScreen)

            let cardWidthPixels = screenSize.width / cardWidthsPerScreen
            self.cardScale = cardWidthPixels / self.cardWidthFullSizePixels
            
            DispatchQueue.main.async {
                self.setScale(self.cardScale)
            }
            
            self.popAction = Actions.getPopAction(originalScale: self.cardScale, scaleBy: self.popScaleBy, duration: self.flipDuration)
        }
        
    }
    
    // MARK: - Public methods - movement
    
    func flip(sendPosition: Bool) {
        //self.shadowNode.position = self.position
        //self.shadowNode.zPosition = self.zPosition - 0.5
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
    
    func moveAndFlip(to newPosition: CGPoint, rotateToAngle newRotation: CGFloat, faceUp: Bool, duration: Double, sendPosition: Bool, animateReceiver: Bool = false) {
        
        //if we're animating at the receiver end, send the position first
        //so that the animations happen simultaneously
        if sendPosition && animateReceiver {
            self.delegate!.sendFuture(position: newPosition, rotation: newRotation, faceUp: faceUp, of: self, moveToFront: true)
        }
        
        self.moving = true
        let movement = SKAction.move(to: newPosition, duration: duration)
        let rotation = SKAction.rotate(toAngle: newRotation, duration: duration)
        let actionGroup = SKAction.group([movement, rotation, self.moveSound])
        self.delegate!.makeMoveSound()
        self.run(actionGroup) {
            if self.faceUp != faceUp {
                self.flip(sendPosition: sendPosition && !animateReceiver)
            } else if sendPosition && !animateReceiver {
                self.delegate!.sendPosition(of: [self], moveToFront: true, animate: false)
            }
            self.moving = false
        }
    }
    
    func rotate(to angle: CGFloat, duration: Double, sendPosition: Bool) {
        let movement = SKAction.rotate(toAngle: angle, duration: duration, shortestUnitArc: true)
        self.run(movement) {
            if sendPosition {
                self.delegate!.sendPosition(of: [self], moveToFront: false, animate: false)
            }
        }
    }
    
    func rotate(by angle: CGFloat, duration: Double, sendPosition: Bool) {
        let movement = SKAction.rotate(byAngle: angle, duration: duration)
        self.run(movement) {
            if sendPosition {
                self.delegate!.sendPosition(of: [self], moveToFront: false, animate: false)
            }
        }
    }
    
    /* Rotate about centre by the angle between the centre and the two points */
    func rotate(from fromPoint: CGPoint, to toPoint: CGPoint) {
        let angle = self.position.angleBetween(pointA: fromPoint, pointB: toPoint)
        self.debugLabel.text = "\(Double(round(self.zRotation*100)/100))\n\(Double(round(angle*100)/100))\n\(Double(round((self.zRotation - angle)*100)/100))"
        self.zRotation -= angle
    }
    
    /* Rotate about the specified point by the angle between the centre and the two points */
    func rotate(from fromPoint: CGPoint, to toPoint: CGPoint, about centrePoint: CGPoint) {
        let angle = centrePoint.angleBetween(pointA: fromPoint, pointB: toPoint)
        self.zRotation -= angle
    }
    
    func rotate(towards towardsAngle: CGFloat, by byAngle: CGFloat) {
        if self.zRotation == towardsAngle {
            return
        }
        
        var newAngle = self.zRotation
        if newAngle < towardsAngle {
            newAngle += byAngle
            if newAngle < towardsAngle {
                self.zRotation = newAngle
            }
        } else {
            newAngle -= byAngle
            if newAngle > towardsAngle {
                self.zRotation = newAngle
            }
        }   
    }
    
    // MARK: - Public methods - ranking/scoring
    
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
    
    
    
    /* returns true if the point is within the card node */
    func pointInCard(_ point: CGPoint) -> Bool {
        let transposedPoint = point.rotateAbout(point: self.position, byAngle: -self.zRotation)
        let cardRect = CGRect(center: self.position, size: self.cardSize)
        return cardRect.contains(transposedPoint)
    }
    
    /* returns true if the point in the mid section of the card node */
    func pointInMidSection(_ point: CGPoint) -> Bool {
        let transposedPoint = point.rotateAbout(point: self.position, byAngle: -self.zRotation)
        let midSection = CGRect(center: self.position, size: CGSize(width: self.cardSize.width, height: self.cardSize.height / 2))
        
        return midSection.contains(transposedPoint)
    }
    
    /* returns true if the point is in one of the corners of the card node */
    func pointInCorner(_ point: CGPoint) -> Bool {
        let transposedPoint = point.rotateAbout(point: self.position, byAngle: -self.zRotation)

        if self.bottomLeftRect.contains(transposedPoint) {
            //print("bottom left")
            return true
        }
        if self.bottomRightRect.contains(transposedPoint) {
            //print("bottom right")
            return true
        }
        if self.topLeftRect.contains(transposedPoint) {
            //print("top left")
            return true
        }
        if self.topRightRect.contains(transposedPoint) {
            //print("top right")
            return true
        }
        
        return false
    }
}


// MARK: - CardSpriteNodeDelegate

protocol CardSpriteNodeDelegate {
    func moveToFront(_ cardNode: CardSpriteNode)
    func sendFuture(position futurePosition: CGPoint, rotation futureRotation: CGFloat, faceUp futureFaceUp: Bool, of cardNode: CardSpriteNode, moveToFront: Bool)
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

