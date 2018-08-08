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
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    let numberOfCards = 0
    let minRank = 6
    let border: CGFloat = 10.0
    let resetDuration = 0.5
    let verticalHeight = 0.2
    let cornerTapSize: CGFloat = 50.0
    let xOffset: CGFloat = 20.0
    let yOffset: CGFloat = 5.0
    let xPeek: CGFloat = 20.0
    let yPeek: CGFloat = 20.0
    let buffer: CGFloat = 100.0
    let forceTouchRatio: CGFloat = 0.9
    let timeToSelectMultipleNodes: TimeInterval = 1.0
    
    //let connectionService = ConnectionServiceManager()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var settings = Settings()
    
    private var lastUpdateTime : TimeInterval = 0
    
    var playerPosition: Position = .bottom
    
    var connectionLabel : SKLabelNode!
    var dividerLine: SKShapeNode!

    var selectedNodes = [CardSpriteNode]()
    var lastSelectedNode = CardSpriteNode()
    var movingSpeed = CGVector()
    var lastTouchTimestamp = 0.0
    var lastSendPositionTimestamp = 0.0
    var lastTouchMoveTimestamp = 0.0
    
    var allCards = [CardSpriteNode]()
    
    var forceTouch = false
    var forceTouchActivated = false
    
    var gameSceneDelegate: GameSceneDelegate?
    
    var moveSound = Actions.getCardMoveSound()
    var flipSound = Actions.getCardFlipSound()
    
    var cutting = false
    var cutStartPosition: CGPoint!
    
    // MARK: - Initializers
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //connectionService.delegate = self

        self.resetGame(sync: false)
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
    }
    
    // MARK: - Private methods
    
    
    // MARK: - Public methods
    
    func resetGame(sync: Bool) {
        self.removeAllChildren()
        
        connectionLabel = SKLabelNode(text: "Connections: ")
        connectionLabel.fontColor = UIColor.green
        connectionLabel.fontSize = 15
        connectionLabel.fontName = "Helvetica"
        connectionLabel.position = CGPoint(x: connectionLabel.frame.width / 2, y: self.frame.height - connectionLabel.frame.height / 2 - border)
        connectionLabel.zPosition = 100
        //self.addChild(connectionLabel)
        
        
        //var points = [CGPoint(x: 0, y: self.frame.height - self.frame.width), CGPoint(x: self.frame.width, y: self.frame.height - self.frame.width)]
        var points = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        self.dividerLine = SKShapeNode(points: &points, count: points.count)
        self.dividerLine.position = CGPoint(x: 0, y: self.frame.height - self.frame.width)
        self.dividerLine.zPosition = -100
        self.dividerLine.strokeColor = Config.mainColor
        self.addChild(self.dividerLine)
        
        self.allCards = Global.newShuffledDeck(name: "deck", settings: self.settings)
        
        for cardNode in self.allCards {
            self.addChild(cardNode)
            self.addChild(cardNode.shadowNode)
        }

        self.resetCards(sync: false)
        
        if sync {
            self.syncToMe()
        }
    }
    
    func resetCards(sync: Bool) {
        Global.shuffle(&self.allCards)
        
        for (cardNumber, cardNode) in self.allCards.enumerated() {
            cardNode.delegate = self
            
            cardNode.selectable = true
            cardNode.moveToFront()
            let cardOffset = CGFloat(Double(cardNumber) * self.verticalHeight)
            cardNode.position = CGPoint(x: self.frame.midX - cardOffset, y: self.dividerLine.position.y + self.frame.width / 2 + cardOffset)
            cardNode.flip(faceUp: false, sendPosition: false)
        }
        if sync {
            self.sendPosition(of: self.allCards, moveToFront: true, animate: false)
        }
    }
    
    func stack(cards: [CardSpriteNode], position: CGPoint) {
        var cardsCopy = [CardSpriteNode]()
        for (cardNumber, card) in cards.enumerated() {
            let cardOffset = CGFloat(Double(cardNumber) * verticalHeight)
            let newPosition = CGPoint(x: position.x + cardOffset, y: position.y - cardOffset)
            card.moveAndFlip(to: newPosition, faceUp: card.faceUp, duration: resetDuration, sendPosition: false)
            
            let cardCopy = card.copy() as! CardSpriteNode
            cardCopy.position = newPosition
            cardCopy.card = card.card
            cardCopy.faceUp = card.faceUp
            cardsCopy.append(cardCopy)
        }
        self.sendPosition(of: cardsCopy, moveToFront: true, animate: true)
    }
    
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
            stack(cards: stack1, position: position1)
            stack(cards: stack2, position: position2)
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
    
    func resetHand(sort: Bool) {
        let usableWidth = self.frame.size.width - (self.border * 2)

        var hand = self.allCards.filter { $0.position.y < self.dividerLine.position.y }
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
            cardNode.moveAndFlip(to: newPosition, faceUp: true, duration: self.resetDuration, sendPosition: true)
        }
    }
    
    func selectNodeForTouch(touchLocation: CGPoint, tapCount: Int) {
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is CardSpriteNode {
            
            // select card to move
            let touchedCardNode = touchedNode as! CardSpriteNode
            if touchedCardNode.selectable {
                //touchedCardNode.moveToFront()
                self.selectedNodes = [touchedCardNode]

                if tapCount > 1 {
                    // this is the second tap - flip the card
                    touchedCardNode.moveToFront()
                    touchedCardNode.flip(sendPosition: true)
                }
                
                //print("Cards under touched node: ", terminator: "")
                //displayCards(self.getCards(under: self.selectedNode))
                self.sendPosition(of: self.selectedNodes, moveToFront: true, animate: false)
            }
        } else {
            print("cutting started")
            self.cutting = true
            self.cutStartPosition = touchLocation
        }
    }
    
    func selectMultipleNodesForTouch(touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is CardSpriteNode {
            AudioServicesPlaySystemSound(1520) // activate 'Pop' feedback
            
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

    func setMovingSpeed(startPosition: CGPoint, endPosition: CGPoint, time: Double) {
        self.movingSpeed.dx = (endPosition.x - startPosition.x) / CGFloat(time)
        self.movingSpeed.dy = (endPosition.y - startPosition.y) / CGFloat(time)
    }
    
    func deselectNodeForTouch() {
        self.selectedNodes.removeAll()
    }

    // MARK: - UIResponder methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        for t in touches {
            self.selectNodeForTouch(touchLocation: t.location(in: self), tapCount: t.tapCount)
            
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
            
            if forceTouch {
                if t.force / t.maximumPossibleForce >= self.forceTouchRatio {
                    // Force touch activated
                    if !forceTouchActivated {
                        forceTouchActivated = true
                        self.selectMultipleNodesForTouch(touchLocation: currentPosition)
                        //self.stack(cards: self.selectedNodes, position: currentPosition)
                    } else {
                        // Need to make cards stack when force touch activated second time?
                        //self.stack(cards: selectedNodes, position: currentPosition)
                    }
                }
            }
            
            //let timeInterval = t.timestamp - lastTouchTimestamp
            //setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
            
            if transformation.x != 0 || transformation.y != 0 {
                self.lastTouchMoveTimestamp = t.timestamp
                if self.selectedNodes.count > 0 {
                    if self.selectedNodes.count == 1 {
                        if self.selectedNodes[0].isOnTopOfPile() {
                            self.selectedNodes[0].moveToFront()
                        }
                    }
                    self.selectedNodes.move(transformation: transformation)
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
            self.forceTouchActivated = false
            
            if self.selectedNodes.count > 0 {
                let currentPosition = t.location(in: self)
                let previousPosition = t.previousLocation(in: self)
                let timeInterval = t.timestamp - self.lastTouchTimestamp
                self.setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)

                DispatchQueue.concurrentPerform(iterations: self.selectedNodes.count) {
                    self.selectedNodes[$0].stopMoving(startSpeed: self.movingSpeed)
                }
                
                self.lastTouchTimestamp = 0.0
                self.lastTouchMoveTimestamp = 0.0
            } else {
                if self.cutting {
                    print("cutting stopped")
                    self.cutting = false
                    self.stoppedCutting(touchLocation: t.location(in: self))
                }
            }
        }
        
        self.deselectNodeForTouch()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.deselectNodeForTouch()
    }
    
    // MARK: - Scene methods
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
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
                // select multiple nodes for devices with no force touch
                forceTouchActivated = true
                selectMultipleNodesForTouch(touchLocation: selectedNodes[0].position)
            }
        }
    }
    
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

                    let newPositionRelative = CGPointFromString(cardDictionary["p"] as! String)
                    var newPositionTransposed = CGPoint()
                    
                    switch self.playerPosition {
                    case .bottom :
                        newPositionTransposed = newPositionRelative
                    case .top :
                        newPositionTransposed.x = 1 - newPositionRelative.x
                        newPositionTransposed.y = 1 - newPositionRelative.y
                    case .left :
                        newPositionTransposed.x = 1 - newPositionRelative.y
                        newPositionTransposed.y = newPositionRelative.x
                    case .right:
                        newPositionTransposed.x = newPositionRelative.y
                        newPositionTransposed.y = 1 - newPositionRelative.x
                    default:
                        break
                    }
                    
                    let newPosition = CGPoint(x: newPositionTransposed.x * self.frame.width, y: newPositionTransposed.y * self.frame.width + self.dividerLine.position.y)
                    //let newPositionInverted = CGPoint(x: self.frame.width - newPosition.x, y: self.frame.height - newPosition.y + self.dividerLine.position.y)
                
                    cardNode?.flip(faceUp: cardDictionary["f"] as! Bool, sendPosition: false)
                    //cardNode?.zPosition = cardDictionary["zPosition"] as! CGFloat
                    
                    if (cardDictionary["m"] as! Bool) {
                        cardNode?.moveToFront()
                    }
                    
                    if cardDictionary["a"] as! Bool {
                        cardNode?.moveAndFlip(to: newPosition, faceUp: (cardNode?.faceUp)!, duration: resetDuration, sendPosition: false)
                    } else {
                        cardNode?.position = newPosition
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
        for eachCardNode in allCards {
            eachCardNode.zPosition -= 1
        }
        cardNode.zPosition = self.lastSelectedNode.zPosition + 1
        self.lastSelectedNode = cardNode
    }
    
    func sendPosition(of cardNodes: [CardSpriteNode], moveToFront: Bool, animate: Bool) {
        
        let cardDictionaryArray = Global.cardDictionaryArray(with: cardNodes, position: self.playerPosition, width: self.frame.width, yOffset: self.dividerLine.position.y, moveToFront: moveToFront, animate: animate)

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
        let cardsOnTopOfCard = self.allCards.filter { (card.frame.contains($0.bottomLeftCorner()) ||
                                                       card.frame.contains($0.bottomRightCorner()) ||
                                                       card.frame.contains($0.topLeftCorner()) ||
                                                       card.frame.contains($0.topRightCorner()))
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
}

// MARK: - Protocol GameSceneDelegate

protocol GameSceneDelegate {
    
    func sendData(data: Data)

}




