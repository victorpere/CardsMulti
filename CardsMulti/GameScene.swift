//
//  GameScene.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity
import AudioToolbox

class GameScene: SKScene {
    /// MCPeerID of this device
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    let numberOfCards = 0
    let minRank = 6
    let border: CGFloat = 10.0
    let resetDuration = 0.5
    let shortDuration = 0.1
    let verticalHeight = 0.2
    let cornerTapSize: CGFloat = 50.0
    let xOffset: CGFloat = 20.0
    let yOffset: CGFloat = 5.0
    let xPeek: CGFloat = 20.0
    let yPeek: CGFloat = 20.0
    let buffer: CGFloat = 100.0
    let forceTouchRatio: CGFloat = 0.9
    let timeToSelectMultipleNodes: TimeInterval = 1.0
    let timeToPopUpMenu: TimeInterval = 1.1
    
    //let connectionService = ConnectionServiceManager()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var settings = Settings()
    
    private var lastUpdateTime : TimeInterval = 0
    
    var playerPosition: Position = .bottom
    
    var connectionLabel : SKLabelNode!
    var dividerLine: SKShapeNode!

    /// Set of cards currently selected for manipulation
    var selectedNodes = [CardSpriteNode]()
    
    var lastSelectedNode = CardSpriteNode()
    var currentMovingSpeed = CGVector()
    var previousMovingSpeed = CGVector()
    var currentRotationSpeed: CGFloat = 0
    var firstTouchLocation = CGPoint()
    var lastTouchTimestamp = 0.0
    var lastSendPositionTimestamp = 0.0
    var lastTouchMoveTimestamp = 0.0
    var touchesBeganTimestamp = 0.0
    var rotating = false
    var canDoubleTap = true
    
    /// Whether the currently selected cards have been moved from the initial touch point
    var cardsMoved = false
    
    /// All the cards in the scene
    var allCards = [CardSpriteNode]()
    
    /// Whether force touch is available on this device
    var forceTouch = false
    
    /// Whether force touch or a long press has been activated
    var forceTouchActivated = false
    
    /// The delegate of the scene (should be the view controller)
    var gameSceneDelegate: GameSceneDelegate?
    
    var moveSound = Actions.getCardMoveSound()
    var flipSound = Actions.getCardFlipSound()
    
    var cutting = false
    var cutStartPosition: CGPoint!
    
    var movingDirection = MovingDirection.none
    var movingDirectionReversed = 0
    
    var peers: [MCPeerID?]!
    
    var playersHands = [0, 0, 0, 0]
    
    /// Locations to which cards should snap to if moved to within a close distance
    var snapLocations = [SnapLocation]()
    
    // MARK: - Initializers
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //connectionService.delegate = self

        //self.resetGame(sync: false, loadSaved: false)
        self.resetGame(sync: false, loadSaved: true)
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
    }
    
    // MARK: - Private methods
    
    /**
     Selects multiple cards or rotate single card to 0
     
     - parameter location: location of the touch
     */
    private func didForceOrLongTouch(at location: CGPoint) {
        self.rotating = false
        self.forceTouchActivated = true
        self.selectMultipleNodesForTouch(touchLocation: location)
        AudioServicesPlaySystemSound(1520) // activate 'Pop' feedback
        
        if self.selectedNodes.count == 1 {
            self.selectedNodes[0].rotate(to: 0, duration: self.shortDuration, sendPosition: true)
        }
    }
    
    // MARK: - Public methods
    
    /**
     Returns the number of cards in the area of the player in the specified position
     
     - parameter position: the player's position
     */
    func numberOfCards(inPosition position: Position) -> Int {
        return self.cards(inPosition: position).count
    }
    
    /**
     Returns the number of connected players
     */
    func numberOfPlayers() -> Int {
        if self.peers == nil {
            return 1
        }
        return self.peers.filter { $0 != nil }.count
    }
    
    /**
     Returns the set of cards in the specified player's area
     
     - parameter position: position of the player
     */
    func cards(inPosition position: Position) -> [CardSpriteNode] {
        switch position {
        case .left:
            return self.allCards.filter { $0.position.x < 0 }
        case .error:
            return []
        case .bottom:
            return self.allCards.filter { $0.position.y < self.dividerLine.position.y }
        case .top:
            return self.allCards.filter { $0.position.y > self.frame.height }
        case .right:
            return self.allCards.filter { $0.position.x > self.frame.width }
        }
    }
    
    /**
     Sets the scene as the delegate for all cards and marks all cards as selectable
     */
    func initCards() {
        for cardNode in self.allCards {
            cardNode.delegate = self
            cardNode.selectable = true
            self.addChild(cardNode)
        }
    }
    
    /**
     Updates the scale of all cards
     */
    func updateUISettings() {
        for card in self.allCards {
            card.updateScale()
        }
    }

    // MARK: - Game methods
    
    /**
     Saves positions of all cards
     */
    func saveGame() {
        GameState.instance.cardNodes = self.allCards
    }
    
    /**
     Load cards from a saved state or start over with a new deck
     
     - parameter fromSaved: whether to load from a saved state
     */
    func loadCards(fromSaved loadSaved: Bool) {
        let loadedCards = GameState.instance.cardNodes
        if loadSaved && loadedCards.count > 0 {
            self.allCards = loadedCards
            self.initCards()
        } else {
            self.allCards = Global.newShuffledDeck(name: "deck", settings: self.settings)
            self.initCards()
            self.resetCards(sync: false)
        }
    }
    
    /**
     Draws a green rectangle node
     */
    func drawNode(rectangle: CGRect) {
        let rectNode = SKShapeNode(rect: rectangle)
        rectNode.zPosition = -1000
        rectNode.strokeColor = .green
        self.addChild(rectNode)
    }
    
    /**
     Initializes the line dividig the common playing area and the player's area
     */
    func initDividerLine(hidden: Bool) {
        var points = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        self.dividerLine = SKShapeNode(points: &points, count: points.count)
        self.dividerLine.position = CGPoint(x: 0, y: self.frame.height - self.frame.width)
        self.dividerLine.zPosition = -100
        self.dividerLine.strokeColor = Config.mainColor
        self.dividerLine.isHidden = hidden
        self.addChild(self.dividerLine)
    }
    
    /**
     Resets the scene, re-initializes all nodes and prepares a new shuffled deck
     
     - parameters:
        - sync: whether to synchronize connected devices to this device after the execution
        - loadSaved: whether to load the save game state
     */
    func resetGame(sync: Bool, loadSaved: Bool = false) {
        self.removeAllChildren()
        
        connectionLabel = SKLabelNode(text: "Connections: ")
        connectionLabel.fontColor = UIColor.green
        connectionLabel.fontSize = 15
        connectionLabel.fontName = "Helvetica"
        connectionLabel.position = CGPoint(x: connectionLabel.frame.width / 2, y: self.frame.height - connectionLabel.frame.height / 2 - border)
        connectionLabel.zPosition = 100
        self.initDividerLine(hidden: false)
        
        self.loadCards(fromSaved: loadSaved)
        
        
        if sync {
            self.syncToMe()
        }
        // trying a snap location
        // TEMPORARY
        /*
         let sl1 = SnapLocation(location: CGPoint(x: 80, y: self.dividerLine.position.y + 80), snapSize: self.allCards[0].size)
         sl1.yOffset = -20
         sl1.snapAreaIncludesCards = true
         self.snapLocations = [sl1]
         */
        
        //draw()
 
    }
    
    /**
     Shuffles all cards and places the shuffled deck in the middle of the playing area
     
     - parameter sync: whether to synchronize with other devices after execution
     */
    func resetCards(sync: Bool) {
        Global.shuffle(&self.allCards)
        
        for (cardNumber, cardNode) in self.allCards.enumerated() {
            cardNode.zRotation = 0
            cardNode.moveToFront()
            let cardOffset = CGFloat(Double(cardNumber) * self.verticalHeight)
            cardNode.position = CGPoint(x: self.frame.midX - cardOffset, y: self.dividerLine.position.y + self.frame.width / 2 + cardOffset)
            cardNode.flip(faceUp: false, sendPosition: false)
        }
        if sync {
            self.sendPosition(of: self.allCards, moveToFront: true, animate: false)
        }
    }
    
    /**
     Deal the specified number of cards into each of the connected players' areas
     
     - parameter numberOfCards: number of cards to deal to each player
     */
    func deal(numberOfCards: Int) {
        var cardsToDeal = self.selectedNodes
        self.deselectNodeForTouch()
        
        DispatchQueue.global(qos: .default).async {
            for _ in 1...numberOfCards {
                for direction in [Position.left, Position.top, Position.right, Position.bottom] {
                    let nextPositionToDealTo = direction.positionTo(self.playerPosition)
                    
                    if self.peers?[nextPositionToDealTo.rawValue] != nil {
                        cardsToDeal = self.deal(to: direction, from: cardsToDeal)
                        usleep(useconds_t(self.resetDuration * 1000000))
                    }
                }
            }
        }
    }
    
    /**
     Deal one card from the top of the passed pile to the specified position
     
     - parameters:
        - position: player's position to deal the card to
        - cards: set of cards to deal from
     
     - returns: Set of cards without the dealt card
     */
    func deal(to position: Position, from cards: [CardSpriteNode]) -> [CardSpriteNode] {
        if cards.count > 0 {
            //  select top card
            var cardsSorted = cards.sorted { $0.zPosition > $1.zPosition }
            let cardToDeal = cardsSorted.first
            // deal the card to somewhere in the area
            let newLocation = randomLocationForPlayer(in: position)
            
            DispatchQueue.main.async {
                cardToDeal?.moveToFront()
                cardToDeal?.moveAndFlip(to: newLocation, rotateToAngle: cardToDeal!.zRotation, faceUp: false, duration: self.resetDuration, sendPosition: true, animateReceiver: true)
            }
            // remove the dealt card from the stack
            cardsSorted.remove(at: 0)
            
            return cardsSorted
        }
        
        return [CardSpriteNode]()
    }
    
    /**
     Returns a random location weighted towards the centre in the specified player's area
     
     - parameter position: position of the player
     */
    func randomLocationForPlayer(in position: Position) -> CGPoint {
        // TODO: move to a CGPoint extension?
        // random point somewhere within the player's area
        // should be weighted towards centre
        
        let xoffset = ((self.frame.width / 2) / CGFloat(Int.random(in: 1...Int(self.frame.width / 2)))) * (Int.random(in: 0...1) == 0 ? 1 : -1)
        let yoffset = ((self.dividerLine.position.y / 2) / CGFloat(Int.random(in: 1...Int(self.dividerLine.position.y / 2)))) * (Int.random(in: 0...1) == 0 ? 1 : -1)

        
        //let newX = CGFloat(Int.random(in: 0...Int(self.frame.width)))
        let newX = self.frame.width / 2 + xoffset
        let newY = self.dividerLine.position.y / 2 + yoffset
        
        var transposedX = newX
        var transposedY = newY
        
        // transpose coordinates to the specified position
        // TODO move this to a method/extension/separate class
        print("deal to \(position)")
        switch position {
        case .bottom:
            break
        case .top:
            transposedX = self.frame.width - newX
            transposedY = self.frame.height + self.dividerLine.position.y - newY
        case .left:
            transposedX = newY - self.dividerLine.position.y
            transposedY = self.frame.height - newX
        case .right:
            transposedX = self.frame.width + self.dividerLine.position.y - newY
            transposedY = self.dividerLine.position.y + newX
        case .error:
            break
        }
        
        return CGPoint(x: transposedX, y: transposedY)
    }
    
    /**
     Stacks selected cards
     */
    func stackSelectedCards() {
        if self.selectedNodes.count > 0 {
            let cardsSorted = self.selectedNodes.sorted { $0.zPosition > $1.zPosition }
            let topCardLocation = (cardsSorted.last?.position)!
            self.stack(cards: cardsSorted, at: topCardLocation)
            self.deselectNodeForTouch()
        }
    }
    
    /**
     Stacks specified cards at the specified location
     
     - parameters:
        - cards: the set of cards to stack
        - location: location to stack the cards at (will be bottom card's location)
        - flip: whether to flip the cards (default is false)
        - faceUp: whether to place all cards face up or down (default is false)
     */
    func stack(cards: [CardSpriteNode], at location: CGPoint, flip: Bool = false, faceUp: Bool = false) {
        let cardsSorted = cards.sorted { $0.zPosition > $1.zPosition }
        var cardsCopy = [CardSpriteNode]()
        for (cardNumber, card) in cardsSorted.enumerated() {
            let cardOffset = CGFloat(Double(cardNumber) * verticalHeight)
            let newPosition = CGPoint(x: location.x + cardOffset, y: location.y - cardOffset)
            card.moveAndFlip(to: newPosition, rotateToAngle: 0, faceUp: flip ? faceUp : card.faceUp, duration: resetDuration, sendPosition: false)
            
            let cardCopy = card.copy() as! CardSpriteNode
            cardCopy.position = newPosition
            cardCopy.card = card.card
            cardCopy.faceUp = card.faceUp
            cardCopy.zRotation = 0
            cardsCopy.append(cardCopy)
        }
        self.sendPosition(of: cardsCopy, moveToFront: true, animate: true)
    }
    
    /**
     Separates the specified set of cards into two stacks
     
     - parameter cards: the set of cards to cut
     */
    func cut(cards: [CardSpriteNode]) {
        if cards.count > 1 {
            let cardsSorted = cards.sorted { $0.zPosition > $1.zPosition }
            let originalPosition  = cardsSorted.first?.position
            var position1 = CGPoint(x: (originalPosition?.x)! - (cardsSorted.first?.frame.size.width)! / 2 - xOffset, y: (originalPosition?.y)!)
            var position2 = CGPoint(x: (originalPosition?.x)! + (cardsSorted.first?.frame.size.width)! / 2 + xOffset, y: (originalPosition?.y)!)
            
            if position1.x < (cardsSorted.first?.frame.width)! / 2 + xOffset {
                position1.x = (cardsSorted.first?.frame.width)! / 2 + border
                position2.x = position1.x + (cardsSorted.first?.frame.width)! + 2 * xOffset
            } else if position2.x > self.frame.width - (cardsSorted.first?.frame.width)! / 2 - xOffset {
                position2.x = self.frame.width - (cardsSorted.first?.frame.width)! / 2 - border
                position1.x = position2.x - (cardsSorted.first?.frame.width)! - 2 * xOffset
            }
            
            let halfIndex: Int = cardsSorted.count / 2
            let stack1 = Array(cardsSorted.prefix(upTo: halfIndex))
            let stack2 = Array(cardsSorted.suffix(from: halfIndex))
            
            //stack(cards: cardsSorted, position: originalPosition!)
            self.stack(cards: stack1, at: position1)
            self.stack(cards: stack2, at: position2)
        }
    }
    
    func stoppedCutting(touchLocation: CGPoint) {
        print ("cutting \(cutStartPosition) -> \(touchLocation)")
        
        let origin = CGPoint(x: min(touchLocation.x, cutStartPosition.x), y: min(touchLocation.y, cutStartPosition.y))
        let width = abs(touchLocation.x - cutStartPosition.x)
        let height = abs(touchLocation.y - cutStartPosition.y)
        let cutRect = CGRect(x: origin.x, y: origin.y, width: width, height: height)
        let cards = self.allCards.filter { cutRect.contains($0.position) }
        self.cut(cards: cards)
    }
    
    /**
     Lines up cards inside the player's area
     
     - parameter sort: whether to order cards by suit and rank
     */
    func resetHand(sort: Bool) {
        let usableWidth = self.frame.size.width - (self.border * 2)

        var hand = self.cards(inPosition: .bottom)
        if sort {
            hand.sort { ($0.card?.rank.rawValue)! < ($1.card?.rank.rawValue)! }
            hand.sort { ($0.card?.suit.rawValue)! < ($1.card?.suit.rawValue)! }
        } else {
            hand.sort { $0.position.x < $1.position.x }
        }
        
        for (nodeNumber, cardNode) in hand.enumerated() {
            
            let node_x = ((usableWidth - cardNode.frame.size.width) / CGFloat(hand.count)) * CGFloat(nodeNumber)
            let newPosition = CGPoint(x: cardNode.frame.size.width / 2 + node_x + border, y: cardNode.frame.size.height / 2 + border)
            cardNode.moveToFront()
            cardNode.moveAndFlip(to: newPosition, rotateToAngle: 0, faceUp: true, duration: self.resetDuration, sendPosition: true)
        }
    }
    
    /**
     Selects a single node at the touch location
     
     - parameters:
        - touchLocation: location of the touch
        - tapCount: number of taps to detect double tap
     */
    func selectNodeForTouch(touchLocation: CGPoint, tapCount: Int) {
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is CardSpriteNode {
            
            // select card to move
            let touchedCardNode = touchedNode as! CardSpriteNode
            if touchedCardNode.selectable {
                //touchedCardNode.moveToFront()
                self.selectedNodes = [touchedCardNode]

                if tapCount > 1 && self.canDoubleTap {
                    // this is the second tap - flip the card
                    touchedCardNode.moveToFront()
                    touchedCardNode.flip(sendPosition: true)
                } else if touchedCardNode.pointInCorner(touchLocation) {
                    // touched in the corner of the card
                    // select for rotation
                    self.rotating = true
                }
                
                self.canDoubleTap = true
                //print("Cards under touched node: ", terminator: "")
                //displayCards(self.getCards(under: self.selectedNode))
                self.sendPosition(of: self.selectedNodes, moveToFront: false, animate: false)
            }
        } else {
            print("cutting started")
            self.cutting = true
            self.cutStartPosition = touchLocation
        }
    }
    
    /**
     Selects multiple cards at the touch location
     
     - parameter touchLocation: location of the touch
     */
    func selectMultipleNodesForTouch(touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is CardSpriteNode {
            //AudioServicesPlaySystemSound(1520) // activate 'Pop' feedback
            
            let touchedCardNode = touchedNode as! CardSpriteNode
            self.selectedNodes = self.getCards(under: touchedCardNode)
            
            for cardNode in self.selectedNodes {
                cardNode.pop()
                cardNode.moveToFront()
            }
            
            print("force touched to drag cards: ", terminator: "")
            Global.displayCards(self.selectedNodes)
            
            //self.stack(cards: self.selectedNodes, position: touchedCardNode.position)
            self.sendPosition(of: self.selectedNodes, moveToFront: true, animate: false)
        }
    }
    
    /**
     Removes the specified cards from snap locations
     
     - parameter cardNodes: the cards to unsnap
     */
    func unSnap(_ cardNodes: [CardSpriteNode]) {
        DispatchQueue.global(qos: .default).async {
            for snapLocation in self.snapLocations {
                snapLocation.unSnap(cardNodes)
            }
        }
    }

    func setMovingSpeed(startPosition: CGPoint, endPosition: CGPoint, time: Double) {
        self.previousMovingSpeed = self.currentMovingSpeed
        self.currentMovingSpeed.dx = (endPosition.x - startPosition.x) / CGFloat(time)
        self.currentMovingSpeed.dy = (endPosition.y - startPosition.y) / CGFloat(time)
    }
    
    /**
     Deselects all cards
     */
    func deselectNodeForTouch() {
        self.selectedNodes.removeAll()
    }
    
    /**
     Shuffles selected cards and deselects them
     */
    func shuffleSelectedCards() {
        if self.selectedNodes.count > 1 {
            self.shuffle(cards: self.selectedNodes)
        }
        self.deselectNodeForTouch()
    }
    
    /**
     Shuffles a set of cards
     
     - parameter cards: set of cards to be shuffled
     */
    func shuffle(cards: [CardSpriteNode]) {
        // TODO: flip before shuffling
        // TODO: shuffling animation
        print("shuffling cards")
        print("old order:")
        Global.displayCards(cards.sorted { $0.zPosition < $1.zPosition })
        let topCardPosition = cards.last?.position
        
        var shuffledCards = cards
        Global.shuffle(&shuffledCards)
        
        for card in shuffledCards {
            card.moveToFront()
        }
        
        // stacking cards also sends position to other devices
        self.stack(cards: cards, at: topCardPosition!, flip: true, faceUp: false)
 
        print("new order:")
        Global.displayCards(cards.sorted { $0.zPosition < $1.zPosition })
    }
    
    /**
     Lines up cards in the shape of a fan
     
     - parameters:
        - cards: set of cards to be lined up
        - faceUp: whether to flip all cards face up
     */
    func fan(cards: [CardSpriteNode], faceUp: Bool) {
        // TODO: fan radius and dist between cards based on number of cards
        let fanRadius: CGFloat = 100
        let radianPerCard: CGFloat = 0.2
        //let arcSize = CGFloat(cards.count) * radianPerCard
        
        let topCardPosition = (cards.last?.position)!
        
        for (cardNumber, card) in cards.sorted(by: { $0.zPosition < $1.zPosition }).enumerated() {
            let offset: CGFloat = CGFloat(cardNumber) - (CGFloat(cards.count - 1) / 2)
            //let offset: CGFloat =  (CGFloat(cards.count - 1) / 2) - CGFloat(cardNumber)
            let angle: CGFloat = radianPerCard * offset
            
            let dx: CGFloat = fanRadius * sin(angle)
            let dy: CGFloat = (fanRadius * cos(angle)) - fanRadius
            
            let newPosition = CGPoint(x: topCardPosition.x + dx, y: topCardPosition.y + dy)
            
            Global.displayCards([card])
            print("Offset: \(offset)")
            print("Old position: \(topCardPosition)")
            print("New Position: \(newPosition)")
            print("Angle: \(angle)")
            
            //card.rotate(to: -angle, duration: self.shortDuration, sendPosition: true)
            card.moveAndFlip(to: newPosition, rotateToAngle: -angle, faceUp: faceUp, duration: self.resetDuration, sendPosition: true, animateReceiver: true)
        }
        
        self.deselectNodeForTouch()
    }

    // MARK: - UIResponder methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        for t in touches {
            self.selectNodeForTouch(touchLocation: t.location(in: self), tapCount: t.tapCount)
            
            self.firstTouchLocation = t.location(in: self)
            self.touchesBeganTimestamp = t.timestamp
            self.lastTouchTimestamp = t.timestamp
            self.lastTouchMoveTimestamp = t.timestamp
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //print("touches moved at \(t.location(in: self)) at \(t.timestamp)")
 
            let currentPosition = t.location(in: self)
            let previousPosition = t.previousLocation(in: self)
            let transformation = CGPoint(x: currentPosition.x - previousPosition.x, y: currentPosition.y - previousPosition.y)
            
            // determine speed of last move
            let timeInterval = t.timestamp - self.lastTouchTimestamp
            self.setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
            
            if forceTouch {
                if t.force / t.maximumPossibleForce >= self.forceTouchRatio {
                    // Force touch activated
                    if !self.forceTouchActivated {
                        self.didForceOrLongTouch(at: currentPosition)
                    }
                }
            }
            
            if transformation.x != 0 || transformation.y != 0 {
                self.canDoubleTap = false
                self.lastTouchMoveTimestamp = t.timestamp
                if self.selectedNodes.count > 0 {
                    self.cardsMoved = true
                    
                    // unsnap the moved cards
                    self.unSnap(self.selectedNodes)
                    
                    if !self.rotating {
                        self.selectedNodes.move(transformation: transformation)
                    }
                    
                    if self.selectedNodes.count == 1 {
                        // check if the card now has no cards over it,
                        // if it doesn't move it to the top
                        if self.selectedNodes[0] != self.lastSelectedNode && self.selectedNodes[0].isOnTopOfPile() {
                            self.selectedNodes[0].moveToFront()
                            self.sendPosition(of: self.selectedNodes, moveToFront: true, animate: false)
                        }
                        
                        if self.rotating {
                            // handle rotation
                            let angle = self.selectedNodes[0].rotate(from: previousPosition, to: currentPosition)
                            self.currentRotationSpeed = angle / CGFloat(timeInterval)
                        }
                    }
                    
                    let timeElapsed = t.timestamp - self.lastSendPositionTimestamp
                    if timeElapsed >= 0.1 || (self.selectedNodes.count <= 2 && timeElapsed >= 0.05) {
                        self.lastSendPositionTimestamp = t.timestamp
                        self.sendPosition(of: self.selectedNodes, moveToFront: false, animate: false)
                    }
                    
                } else {
                    if self.cutting {
                        let transformationFromStart = CGPoint(x: currentPosition.x - self.cutStartPosition.x, y: currentPosition.y - cutStartPosition.y)
                        if ((transformationFromStart.x < 0) != (transformation.x < 0)) || ((transformationFromStart.y < 0) != (transformation.y < 0)) {
                            self.cutting = false
                            print("cutting interrupted")
                        } else {
                            print("cutting continued")
                        }
                    }
                }
            }
            
            self.lastTouchTimestamp = t.timestamp
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if t.tapCount > 1 {
                return
            }
            
            self.forceTouchActivated = false
            self.movingDirectionReversed = 0
            
            if self.selectedNodes.count > 0 {
                // inertia movement
                // only if one card is selected
                if self.selectedNodes.count == 1 && (self.previousMovingSpeed.dx != 0 || self.previousMovingSpeed.dy != 0) && self.previousMovingSpeed.direction == self.currentMovingSpeed.direction {
                    if self.rotating {
                        self.selectedNodes[0].stopRotating(startSpeed: self.currentRotationSpeed)
                    } else {
                        DispatchQueue.concurrentPerform(iterations: self.selectedNodes.count) {
                            self.selectedNodes[$0].stopMoving(startSpeed: self.currentMovingSpeed)
                        }
                    }
                } else if self.cardsMoved {
                    self.snap(self.selectedNodes)
                }
                                
                self.lastTouchTimestamp = 0.0
                self.lastTouchMoveTimestamp = 0.0
                let touchLocation = t.location(in: self)
                
                // pop up cotextual menu, if multiple cards were selected
                // and the cards were't being moved
                // and less that a certain time interval elapsed since touches began
                // should contain: deal, shuffle
                let timeSinceTouchesBegan = t.timestamp - self.touchesBeganTimestamp
                if self.selectedNodes.count > 1 &&
                self.firstTouchLocation == touchLocation &&
                    (timeSinceTouchesBegan < self.timeToPopUpMenu || !self.forceTouch) {
                    self.gameSceneDelegate?.presentPopUpMenu(numberOfCards: self.selectedNodes.count, numberOfPlayers: self.numberOfPlayers(), at: touchLocation)
                    return
                }
                
            } else {
                if self.cutting {
                    print("cutting stopped")
                    self.cutting = false
                    self.stoppedCutting(touchLocation: t.location(in: self))
                }
            }
        }
                
        self.rotating = false
        self.cardsMoved = false
        self.deselectNodeForTouch()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.rotating = false
        self.cardsMoved = false
        self.deselectNodeForTouch()
    }
    
    // MARK: - Scene methods
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        DispatchQueue.global(qos: .default).async {
            // update number of cards in each position
            // in order to update player labels
            for positionIndex in 1...3 {
                if let position = Position.init(rawValue: positionIndex) {
                    let numberOfCards = self.numberOfCards(inPosition: position)
                    if numberOfCards != self.playersHands[positionIndex] {
                        self.playersHands[positionIndex] = numberOfCards
                        self.gameSceneDelegate?.updatePlayer(numberOfCards: numberOfCards, inPosition: position)
                    }
                }
            }
        }
        
        // Debug labels
        DispatchQueue.global(qos: .default).async {
            for cardNode in self.allCards {
                DispatchQueue.main.async {
                    //cardNode.debugLabel.zRotation = 0
                    cardNode.debugLabel.text = "\(Double(round(cardNode.zPosition*100)/100))"
                }
            }
        }
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        if !forceTouch {
            if selectedNodes.count == 1 && !forceTouchActivated && lastTouchMoveTimestamp != 0.0 && currentTime - lastTouchMoveTimestamp >= timeToSelectMultipleNodes {
                self.didForceOrLongTouch(at: selectedNodes[0].position)
            }
        }
    }
    
    // MARK: - Network sync methods
    
    /**
     Synchronizes all connected devices to this one
     */
    func syncToMe() {
        self.syncDeckReset()
        self.sendPosition(of: self.allCards, moveToFront: true, animate: false)
    }
    
    func syncDeckReset() {
        let settingsDictionary = [ "minRank" : self.settings.minRank,
                                   "maxRank" : self.settings.maxRank,
                                   "jack" : self.settings.jack,
                                   "queen" : self.settings.queen,
                                   "king" : self.settings.king,
                                   "ace" : self.settings.ace] as [String : Any]
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: settingsDictionary)
        self.gameSceneDelegate!.sendData(data: encodedData)
    }
    
    /**
     Handles received sychronization data (settings or cards)
     
     - parameter data: data containing synchronization dictionary
     */
    func receivedData(data: Data) {
        
        if let receivedSettings = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary {
            self.settings.minRank = (receivedSettings["minRank"] as? Int)!
            self.settings.maxRank = (receivedSettings["maxRank"] as? Int)!
            self.settings.jack = (receivedSettings["jack"] as? Bool)!
            self.settings.queen = (receivedSettings["queen"] as? Bool)!
            self.settings.king = (receivedSettings["king"] as? Bool)!
            self.settings.ace = (receivedSettings["ace"] as? Bool)!
            self.resetGame(sync: false)
        } else {
        
            do {
                let cardDictionaryArray = try JSONSerialization.jsonObject(with: data) as! NSArray
                
                for cardDictionaryArrayElement in cardDictionaryArray {
                    let cardDictionary = cardDictionaryArrayElement as! NSDictionary
                    
                    let cardSymbol = cardDictionary["c"] as! String
                    let cardNode = self.allCards.filter { $0.card?.symbol() == cardSymbol }.first

                    let newPositionRelative = cardDictionary["p"] != nil ? NSCoder.cgPoint(for: cardDictionary["p"] as! String) : CGPoint()
                    var newPositionTransposed = CGPoint()
                    
                    let newRotationRelative = cardDictionary["r"] != nil ? cardDictionary["r"] as! CGFloat : CGFloat()
                    var newRotation = CGFloat()
                    
                    switch self.playerPosition {
                    case .bottom :
                        newPositionTransposed = newPositionRelative
                        newRotation = newRotationRelative
                    case .top :
                        newPositionTransposed.x = 1 - newPositionRelative.x
                        newPositionTransposed.y = 1 - newPositionRelative.y
                        newRotation = newRotationRelative - CGFloat.pi
                    case .left :
                        // UNTESTED
                        newPositionTransposed.x = 1 - newPositionRelative.y
                        newPositionTransposed.y = newPositionRelative.x
                        newRotation = newRotationRelative + CGFloat.pi / 2
                    case .right:
                        // UNTESTED
                        newPositionTransposed.x = newPositionRelative.y
                        newPositionTransposed.y = 1 - newPositionRelative.x
                        newRotation = CGFloat.pi / 2 - newRotationRelative - CGFloat.pi / 2
                    default:
                        break
                    }
                    
                    let newPosition = CGPoint(x: newPositionTransposed.x * self.frame.width, y: newPositionTransposed.y * self.frame.width + self.dividerLine.position.y)
                    //let newPositionInverted = CGPoint(x: self.frame.width - newPosition.x, y: self.frame.height - newPosition.y + self.dividerLine.position.y)
                
                    let faceUp = cardDictionary["f"] as! Bool
                    
                    if (cardDictionary["m"] as! Bool) {
                        cardNode?.moveToFront()
                        Global.displayCards([cardNode!])
                    }
                    
                    if cardDictionary["a"] as! Bool {
                        cardNode?.moveAndFlip(to: newPosition, rotateToAngle: newRotation, faceUp: faceUp, duration: self.resetDuration, sendPosition: false)
                    } else {
                        cardNode?.flip(faceUp: cardDictionary["f"] as! Bool, sendPosition: false)
                        cardNode?.position = newPosition
                        cardNode?.zRotation = newRotation
                    }
                }
            } catch {
                print("Error deserializing json data \(error)")
            }
        }
    }
    

}


// MARK: - CardSpriteNodeDelegate

extension GameScene : CardSpriteNodeDelegate {
    func moveToFront(_ cardNode: CardSpriteNode) {
        for eachCardNode in self.allCards.filter({ $0.zPosition >= cardNode.zPosition }) {
            eachCardNode.zPosition -= 1
        }
        cardNode.zPosition = self.lastSelectedNode.zPosition + 1
        self.lastSelectedNode = cardNode
    }
    
    func moveToBack(_ cardNode: CardSpriteNode) {
        for eachCardNode in self.allCards {
            eachCardNode.zPosition += 1
        }
        cardNode.zPosition = self.allCards.min { $0.zPosition < $1.zPosition }!.zPosition - 1
    }
    
    func sendFuture(position futurePosition: CGPoint, rotation futureRotation: CGFloat, faceUp futureFaceUp: Bool, of cardNode: CardSpriteNode, moveToFront: Bool) {
        let cardDictionary = Global.cardDictionary(for: cardNode, cardPosition: futurePosition, cardRotation: futureRotation, faceUp: futureFaceUp, playerPosition: self.playerPosition, width: self.frame.width, yOffset: self.dividerLine.position.y, moveToFront: moveToFront, animate: true)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: [cardDictionary])
            self.gameSceneDelegate!.sendData(data: jsonData)
        } catch {
            print("Error serializing json data: \(error)")
        }
    }
    
    func sendPosition(of cardNodes: [CardSpriteNode], moveToFront: Bool, animate: Bool) {
        
        let cardDictionaryArray = Global.cardDictionaryArray(with: cardNodes, playerPosition: self.playerPosition, width: self.frame.width, yOffset: self.dividerLine.position.y, moveToFront: moveToFront, animate: animate)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cardDictionaryArray)
            self.gameSceneDelegate!.sendData(data: jsonData)
        } catch {
            print("Error serializing json data: \(error)")
        }

    }
    
    func getCards(under card: CardSpriteNode) -> [CardSpriteNode] {
        let cards = self.allCards.filter { card.frame.contains($0.position) }
        return cards.sorted { $0.zPosition < $1.zPosition }
    }
    
    func isOnTopOfPile(_ card: CardSpriteNode) -> Bool {
        let cardsOnTopOfCard = self.allCards.filter { (card.frame.contains($0.bottomLeftCorner) || card.frame.contains($0.bottomRightCorner) ||
            card.frame.contains($0.topLeftCorner) ||
            card.frame.contains($0.topRightCorner))
                                                        && $0.zPosition > card.zPosition }
        return cardsOnTopOfCard.count == 0;
    }
    
    func makeMoveSound() {
        if !self.hasActions() {
            self.run(self.moveSound)
        }
    }
    
    func makeFlipSound() {
        if !self.hasActions() {
            self.run(self.flipSound)
        }
    }
    
    func snap(_ cardNodes: [CardSpriteNode]) {
        DispatchQueue.global(qos: .default).async {
            let cardNodesSorted = cardNodes.sorted { $0.zPosition < $1.zPosition }
            if let bottomCard = cardNodesSorted.first {
                for snapLocation in self.snapLocations {
                    if snapLocation.shouldSnap(cardNode: bottomCard) {
                        snapLocation.snap(cardNodes)
                        break
                    }
                }
            }
        }        
    }
}

// MARK: - Protocol GameSceneDelegate

protocol GameSceneDelegate {
    
    func sendData(data: Data)

    func peers() -> [MCPeerID?]
    
    func presentPopUpMenu(numberOfCards: Int, numberOfPlayers: Int, at location: CGPoint)
    
    func updatePlayer(numberOfCards: Int, inPosition position: Position)
}




