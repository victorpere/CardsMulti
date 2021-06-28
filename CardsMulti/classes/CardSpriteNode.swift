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
    
    let dragCoefficient = 4.0
    let accelerationTimeInterval = 0.001

    static let cardWidthFullSizePixels: CGFloat = 500.0
    let cardWidthsPerScreen: CGFloat = 6.0
    static let cardHeightFullSizePixels: CGFloat = 726.0
    //let cardHeightsPerScreen: CGFloat = CGFloat(1334.0 / 145.2) // 181.5)
    static let flipDuration = 0.2
    let backImageName = "back"
    let cornerSizeRatio: CGFloat = 0.25  // relative to width
    
    /// Vertical and horizontal offset when cards are being stacked on top of eachother
    static let stackOffset: CGFloat = 0.2
    
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
    
    /// The location this card is snapped to
    var snapLocation: SnapLocation?
    var snapLocationName: String?
    
    var snapBackToLocation: SnapLocation?
    
    var movingSpeed: CGFloat = 0
    var rotationSpeed: CGFloat = 0
    
    // MARK: - Computed properties
    
    var cardWidth: CGFloat { return CardSpriteNode.cardWidthFullSizePixels * self.cardScale }
    var cardHeight: CGFloat { return CardSpriteNode.cardHeightFullSizePixels * self.cardScale }
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
                "symbol": self.card!.symbol,
                "suit": self.card!.suit.rawValue,
                "rank": self.card!.rank.rawValue,
                "faceUp": self.faceUp,
                "rotation": self.zRotation,
                "x": self.position.x,
                "y": self.position.y,
                "z": self.zPosition,
                "snap": self.snapLocation?.name ?? ""
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
        self.snapLocationName = cardInfo["snap"] as? String
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
            self.flipToFrontAction = Actions.getFlipAction(texture: self.frontTexture!, duration: CardSpriteNode.flipDuration)
            self.flipToBackAction = Actions.getFlipAction(texture: self.backTexture!, duration: CardSpriteNode.flipDuration)
            
            self.shadowFlipAction = Actions.getShadowFlipAction(duration: CardSpriteNode.flipDuration)
        } else {
            let flipFirstHalfFlip = SKAction.scaleX(to: 0.0, duration: CardSpriteNode.flipDuration)
            let flipSecondHalfFlip = SKAction.scaleX(to: self.cardScale, duration: CardSpriteNode.flipDuration)
            let textureChangeToFront = SKAction.setTexture(self.frontTexture!)
            let textureChangeToBack = SKAction.setTexture(self.backTexture!)
            
            self.flipToFrontAction = SKAction.sequence([flipFirstHalfFlip, textureChangeToFront, flipSecondHalfFlip])
            self.flipToBackAction = SKAction.sequence([flipFirstHalfFlip, textureChangeToBack, flipSecondHalfFlip])
            
            self.shadowFlipAction = SKAction.sequence([flipFirstHalfFlip, flipSecondHalfFlip])
        }
        
        self.popAction = Actions.getPopAction(originalScale: self.cardScale, scaleBy: self.popScaleBy, duration: CardSpriteNode.flipDuration)
        
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
        self.debugLabel.position = CGPoint(x: 0, y: CardSpriteNode.cardHeightFullSizePixels / 2 + 20)
        self.debugLabel.zPosition = 1000
        self.debugLabel.isUserInteractionEnabled = true
        
        //self.addChild(self.debugLabel)
    }
    
    // MARK: - Static public methods
    
    static public func cardWidthPixels(forCardWidthsPerScreen cardWidthsPerScreen: CGFloat) -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        return screenSize.width / cardWidthsPerScreen
    }
    
    static public func cardHeightPixels(forCardWidthsPerScreen cardWidthsPerScreen: CGFloat) -> CGFloat {
        let cardWidthPixels = CardSpriteNode.cardWidthPixels(forCardWidthsPerScreen: cardWidthsPerScreen)
        let scale = cardWidthPixels / CardSpriteNode.cardWidthFullSizePixels
        return CardSpriteNode.cardHeightFullSizePixels * scale
    }
    
    // MARK: - Private methods
    
    private func getScale() -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let cardWidthsPerScreen = CGFloat(StoredSettings.instance.cardWidthsPerScreen)

        let cardWidthPixels = screenSize.width / cardWidthsPerScreen
        return cardWidthPixels / CardSpriteNode.cardWidthFullSizePixels
    }
    
    fileprivate func performMovements(_ movements: [SKAction]) {
        let movementSequence = SKAction.sequence(movements)
        self.delegate!.makeMoveSound()
        self.run(movementSequence) {
            self.delegate.snap([self])
            self.moving = false
            self.delegate!.sendPosition(of: [self], moveToFront: false, animate: false)
        }
    }
    
    // MARK: - Public methods
    
    public func updateScale() {
        DispatchQueue.global(qos: .default).async {
            let screenSize: CGRect = UIScreen.main.bounds
            let cardWidthsPerScreen = CGFloat(StoredSettings.instance.cardWidthsPerScreen)

            let cardWidthPixels = screenSize.width / cardWidthsPerScreen
            self.cardScale = cardWidthPixels / CardSpriteNode.cardWidthFullSizePixels
            
            DispatchQueue.main.async {
                self.setScale(self.cardScale)
            }
            
            self.popAction = Actions.getPopAction(originalScale: self.cardScale, scaleBy: self.popScaleBy, duration: CardSpriteNode.flipDuration)
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
    
    func move(transformation: CGPoint, rotateBy rotationAngle: CGFloat = 0) {
        self.moving = true
        let currentPosition = self.position
        self.position = CGPoint(x: currentPosition.x + transformation.x, y: currentPosition.y + transformation.y)
        self.zRotation = self.zRotation + rotationAngle
        self.delegate!.sendPosition(of: [self], moveToFront: true, animate: false)
    }
    
    /**
     Decelerates moving card
     
     - parameter startSpeed: initial speed
     */
    func stopMoving(startSpeed: CGVector) {
        self.moving = true
        
        var currentSpeed = startSpeed
        var linearSpeed = Math.hypotenuse(from: currentSpeed)
        let linearAcceleration = linearSpeed * self.dragCoefficient
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
            self.performMovements(movements)
        } else {
            self.moving = false
        }
    }
    
    /**
     Decelerates rotating card
     
     - parameter startSpeed: initial rotation speed
     */
    func stopRotating(startSpeed: CGFloat) {
        self.moving = true
        var currentSpeed = startSpeed
        let acceleration = currentSpeed * CGFloat(self.dragCoefficient)
        
        var movements = [SKAction]()
        while currentSpeed.sign == startSpeed.sign {
            let angle = currentSpeed * CGFloat(self.accelerationTimeInterval)
            let movement = SKAction.rotate(byAngle: -angle, duration: self.accelerationTimeInterval)
            movements.append(movement)
            currentSpeed -= acceleration * CGFloat(self.accelerationTimeInterval)
        }
        
        if movements.count > 0 {
            self.performMovements(movements)
        } else {
            self.moving = false
        }
    }
    
    func moveAndFlip(to newPosition: CGPoint, rotateToAngle newRotation: CGFloat, faceUp: Bool, duration: Double, sendPosition: Bool, animateReceiver: Bool = false, moveToFrontReceiver: Bool = true) {
        
        //if we're animating at the receiver end, send the position first
        //so that the animations happen simultaneously
        if sendPosition && animateReceiver {
            self.delegate!.sendFuture(position: newPosition, rotation: newRotation, faceUp: faceUp, of: self, moveToFront: moveToFrontReceiver)
        }
        
        self.moving = true
        let movement = SKAction.move(to: newPosition, duration: duration)
        let rotation = SKAction.rotate(toAngle: newRotation, duration: duration, shortestUnitArc: true)
        let actionGroup = SKAction.group([movement, rotation])
        self.delegate!.makeMoveSound()
        self.run(actionGroup) {
            if self.faceUp != faceUp {
                self.flip(sendPosition: sendPosition && !animateReceiver)
            } else if sendPosition && !animateReceiver {
                self.delegate!.sendPosition(of: [self], moveToFront: moveToFrontReceiver, animate: false)
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
    
    /**
     Rotate about centre by the angle between the centre and the two points
     
     - parameters:
        - fromPoint: point to rotate from
        - toPoint: point to rotate to
     
     -  returns: Angle the card was rotated by
     */
    func rotate(from fromPoint: CGPoint, to toPoint: CGPoint) -> CGFloat {
        let angle = self.position.angleBetween(pointA: fromPoint, pointB: toPoint)
        //self.debugLabel.text = "\(Double(round(self.zRotation*100)/100))\n\(Double(round(angle*100)/100))\n\(Double(round((self.zRotation - angle)*100)/100))"
        self.zRotation -= angle
        return angle
    }
    
    /**
     Rotate about the specified point by the angle between the centre and the two points
     
     - parameters:
        - fromPoint: point to rotate from
        - toPoint: point to rotate to
        - centrePoint: rotation centre
     */
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
        delegate?.moveToFront(self)
    }
    
    func moveToBack() {
        delegate?.moveToBack(self)
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
    
    /**
     Determins whether the specified point if within this card node
     
     - parameter point: the point to examine
     
     - returns: true if the point is within the card node
     */
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
    func moveToBack(_ cardNode: CardSpriteNode)
    func sendFuture(position futurePosition: CGPoint, rotation futureRotation: CGFloat, faceUp futureFaceUp: Bool, of cardNode: CardSpriteNode, moveToFront: Bool)
    func sendPosition(of cardNodes: [CardSpriteNode], moveToFront: Bool, animate: Bool)
    func sendZPositions()
    func getCards(under card: CardSpriteNode) -> [CardSpriteNode]
    func isOnTopOfPile(_ cardNode: CardSpriteNode) -> Bool
    //func makeHumanPlayerHandSelectable()
    //func play(_ cardNode: CardSpriteNode) -> CGPoint
    func makeMoveSound()
    func makeFlipSound()
    func snap(_ cardNodes: [CardSpriteNode])
}


// MARK: - Array of CardSpriteNode extension

extension Array where Element:CardSpriteNode {
    
    /// Returns a string array representing the card symbols in order of their zPositions
    var zPositionsArray: [String?] {
        let cardsSorted = self.sorted { $0.zPosition < $1.zPosition }
        let zPositionsArray = cardsSorted.map { $0.card?.symbol }
        return zPositionsArray
    }

    func move(transformation: CGPoint, rotateBy rotationAngle: CGFloat = 0) {
        for cardNode in self.sorted(by: { $0.zPosition < $1.zPosition }) {
            cardNode.moving = true
            let currentPosition = cardNode.position
            cardNode.position = CGPoint(x: currentPosition.x + transformation.x, y: currentPosition.y + transformation.y)
            cardNode.zRotation = cardNode.zRotation + rotationAngle
        }
    }
    
    /**
     Stacks the array of cards at the specified position
     
     - parameters:
        - position: position in the scene at which to stack the cards
        - flipEachCard: whether to flip each card to the same side or not. Default is false
        - faceUp: whether to flip cards face up or face down, if flipEachCard is true. Default is false (face down)
        - reverseStack: whether to stack the cards in reverse order. Default is false.
        - sendPosition: whether to send the position of all the cards to the peers
        - animateReceiver: whether to animate the stacking at each peer, if sendPosition is true. Default is false
        - delegate: 
     */
    func stack(atPosition position: CGPoint, flipEachCard: Bool = false, faceUp: Bool = false, reverseStack: Bool = false, sendPosition: Bool, animateReceiver: Bool = false, delegate: CardSpriteNodeDelegate) {
        let cardsSorted = self.sorted { reverseStack ? $0.zPosition > $1.zPosition : $0.zPosition < $1.zPosition }
        
        for (cardNumber, card) in cardsSorted.enumerated() {
            let cardOffset = CGFloat(cardNumber) * CardSpriteNode.stackOffset
            let newPosition = CGPoint(x: position.x + cardOffset, y: position.y + cardOffset)
            
            card.moveToFront()
            card.moveAndFlip(to: newPosition, rotateToAngle: 0, faceUp: flipEachCard ? faceUp : card.faceUp, duration: CardSpriteNode.flipDuration, sendPosition: sendPosition, animateReceiver: animateReceiver, moveToFrontReceiver: false)
        }
        
        if sendPosition {
            delegate.sendZPositions()
        }
    }
    
    /**
     Reverses the top/bottom order of a set of cards
     */
    func reverseOrder() {
        for card in self.sorted(by: { $0.zPosition > $1.zPosition }) {
            card.moveToFront()
        }
    }
    
    /**
     
     */
    func fan(flipEachCard: Bool = false, faceUp: Bool = false, sendPosition: Bool, animateReceiver: Bool = false) {        
        if let topCardPosition = (self.last?.position) {
            // TODO: fan radius and dist between cards based on number of cards
            let fanRadius: CGFloat = 100
            let radianPerCard: CGFloat = 0.2
            //let arcSize = CGFloat(cards.count) * radianPerCard
            
            for (cardNumber, card) in self.sorted(by: { $0.zPosition < $1.zPosition }).enumerated() {
                let offset: CGFloat = CGFloat(cardNumber) - (CGFloat(self.count - 1) / 2)
                let angle: CGFloat = radianPerCard * offset
                
                let dx: CGFloat = fanRadius * sin(angle)
                let dy: CGFloat = (fanRadius * cos(angle)) - fanRadius
                
                let newPosition = CGPoint(x: topCardPosition.x + dx, y: topCardPosition.y + dy)
                
                Global.displayCards([card])
                print("Offset: \(offset)")
                print("Old position: \(topCardPosition)")
                print("New Position: \(newPosition)")
                print("Angle: \(angle)")
                
                card.moveAndFlip(to: newPosition, rotateToAngle: -angle, faceUp: faceUp, duration: CardSpriteNode.flipDuration, sendPosition: true, animateReceiver: true)
            }
        }
    }
    
    /**
     Handles received array of card data
     */
    func handle(recievedCardDictionaryArray cardDictionaryArray: NSArray, forScene scene: GameScene) {
        
        for arrayElement in cardDictionaryArray {
            if let cardSymbol = arrayElement as? String {
                guard let cardNode = self.filter({ $0.card?.symbol == cardSymbol}).first else { break }
                cardNode.moveToFront()
                Global.displayCards([cardNode])
            }
            
            else if let cardDictionary = arrayElement as? NSDictionary {
                guard let cardSymbol = cardDictionary["c"] as? String else { break }
                guard let cardNode = self.filter({ $0.card?.symbol == cardSymbol}).first else { break }
                guard let codedPosition = cardDictionary["p"] as? String else { break }
                let position = NSCoder.cgPoint(for: codedPosition)
                guard let rotation = cardDictionary["r"] as? CGFloat else { break }
                guard let animate = cardDictionary["a"] as? Bool else { break }
                guard let moveToFront = cardDictionary["m"] as? Bool else { break }
                guard let faceUp = cardDictionary["f"] as? Bool else { break }
                
                let transposedPosition = scene.playerPosition.transpose(position: position)
                let transposedRotation = scene.playerPosition.transpose(rotation: rotation)
                
                if moveToFront {
                    cardNode.moveToFront()
                }
                
                let newPosition = CGPoint(x: transposedPosition.x * scene.frame.width, y: transposedPosition.y * scene.frame.width + scene.dividerLine.position.y)
                
                if animate {
                    cardNode.moveAndFlip(to: newPosition, rotateToAngle: transposedRotation, faceUp: faceUp, duration: scene.resetDuration, sendPosition: false)
                } else {
                    cardNode.flip(faceUp: faceUp, sendPosition: false)
                    cardNode.position = newPosition
                    cardNode.zRotation = transposedRotation
                }
                
                Global.displayCards([cardNode])
            }
        }
    }
}

