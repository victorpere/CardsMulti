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
        dividerLine = SKShapeNode(points: &points, count: points.count)
        dividerLine.position = CGPoint(x: 0, y: self.frame.height - self.frame.width)
        dividerLine.zPosition = -100
        dividerLine.strokeColor = UIColor(colorLiteralRed: 183, green: 180, blue: 125, alpha: 0.3)
        self.addChild(dividerLine)
        
        allCards = newShuffledDeck(minRank: minRank, numberOfCards: numberOfCards, name: "deck", settings: settings)
        /*
        let newCard = CardSpriteNode(card: Card(suit: Suit.spades, rank: Rank.queen), name: "deck")
        allCards.append(newCard)
        let newCard2 = CardSpriteNode(card: Card(suit: Suit.diamonds, rank: .six), name: "deck")
        allCards.append(newCard2)
        */
        
        for cardNode in allCards {
            self.addChild(cardNode)
            self.addChild(cardNode.shadowNode)
        }

        self.resetCards(sync: false)
        
        if sync {
            self.syncToMe()
        }
    }
    
    func resetCards(sync: Bool) {
        shuffle(&allCards)
        
        for (cardNumber, cardNode) in allCards.enumerated() {
            cardNode.delegate = self
            cardNode.flip(faceUp: false, sendPosition: false)
            cardNode.selectable = true
            //cardNode.zPosition = CGFloat(0 - cardNumber)
            cardNode.moveToFront()
            let cardOffset = CGFloat(Double(cardNumber) * verticalHeight)
            cardNode.position = CGPoint(x: self.frame.midX - cardOffset, y: self.dividerLine.position.y + self.frame.width / 2 + cardOffset)
            //cardNode.position = CGPoint(x: cardNode.frame.size.width / 2 + self.frame.midX + cardOffset, y: self.frame.size.height - (self.dividerLine.position.y + self.frame.width / 2) - cardNode.frame.size.height / 2 - cardOffset)

        }
        if sync {
            self.sendPosition(of: allCards, moveToFront: true, animate: false)
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
    
    func resetHand() {
        let usableWidth = self.frame.size.width - (border * 2)

        let hand = allCards.filter { $0.position.y < self.dividerLine.position.y }
        
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
                touchedCardNode.moveToFront()
                self.selectedNodes = [touchedCardNode]

                if tapCount > 1 {
                    // this is the second tap - flip the card
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
            displayCards(self.selectedNodes)
            
            //self.stack(cards: self.selectedNodes, position: touchedCardNode.position)
            self.sendPosition(of: self.selectedNodes, moveToFront: true, animate: false)
        }
    }

    func setMovingSpeed(startPosition: CGPoint, endPosition: CGPoint, time: Double) {
        movingSpeed.dx = (endPosition.x - startPosition.x) / CGFloat(time)
        movingSpeed.dy = (endPosition.y - startPosition.y) / CGFloat(time)
    }
    
    func deselectNodeForTouch() {
        selectedNodes.removeAll()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        for t in touches {
            selectNodeForTouch(touchLocation: t.location(in: self), tapCount: t.tapCount)
            
            lastTouchTimestamp = t.timestamp
            lastTouchMoveTimestamp = t.timestamp
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //print("touches moved at \(t.location(in: self)) at \(t.timestamp)")
 
            let currentPosition = t.location(in: self)
            let previousPosition = t.previousLocation(in: self)
            let transformation = CGPoint(x: currentPosition.x - previousPosition.x, y: currentPosition.y - previousPosition.y)
            
            if forceTouch {
                //print("touch moved force: \(t.force)")
                if !forceTouchActivated && t.force / t.maximumPossibleForce >= self.forceTouchRatio {
                    forceTouchActivated = true
                    selectMultipleNodesForTouch(touchLocation: t.location(in: self))
                }
            }
            
            //let timeInterval = t.timestamp - lastTouchTimestamp
            //setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
            
            if transformation.x != 0 || transformation.y != 0 {
                lastTouchMoveTimestamp = t.timestamp
                if selectedNodes.count > 0 {
                    selectedNodes.move(transformation: transformation)
                    let timeElapsed = t.timestamp - lastSendPositionTimestamp
                    if timeElapsed >= 0.1 || (selectedNodes.count <= 2 && timeElapsed >= 0.05) {
                        lastSendPositionTimestamp = t.timestamp
                        self.sendPosition(of: selectedNodes, moveToFront: false, animate: false)
                    }
                } else {
                    if self.cutting {
                        let transformationFromStart = CGPoint(x: currentPosition.x - cutStartPosition.x, y: currentPosition.y - cutStartPosition.y)
                        if ((transformationFromStart.x < 0) != (transformation.x < 0)) || ((transformationFromStart.y < 0) != (transformation.y < 0)) {
                            self.cutting = false
                            print("cutting interrupted")
                        } else {
                            print("cutting continued")
                        }
                    }
                }
            }
            lastTouchTimestamp = t.timestamp
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            forceTouchActivated = false
            
            if selectedNodes.count > 0 {
                let currentPosition = t.location(in: self)
                let previousPosition = t.previousLocation(in: self)
                let timeInterval = t.timestamp - lastTouchTimestamp
                setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
                //print("touches ended")
                
                for node in selectedNodes {
                    node.stopMoving(startSpeed: movingSpeed)
                }
                
                lastTouchTimestamp = 0.0
                lastTouchMoveTimestamp = 0.0
            } else {
                if cutting {
                    print("cutting stopped")
                    cutting = false
                    self.stoppedCutting(touchLocation: t.location(in: self))
                }
            }
        }
        
        deselectNodeForTouch()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        deselectNodeForTouch()
    }
    
    
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
}


/*
 ConnectionServiceManagerDelegate
 */

extension GameScene {
    
    
    func receivedData(manager: ConnectionServiceManager, data: Data) {
        
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
                    let cardNode = allCards.filter { $0.card?.symbol() == cardSymbol }.first

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


/*
 CardSpriteNodeDelegate
 */

extension GameScene : CardSpriteNodeDelegate {
    func moveToFront(_ cardNode: CardSpriteNode) {
        for eachCardNode in allCards {
            eachCardNode.zPosition -= 1
        }
        cardNode.zPosition = lastSelectedNode.zPosition + 1
        lastSelectedNode = cardNode
    }
    
    func sendPosition(of cardNodes: [CardSpriteNode], moveToFront: Bool, animate: Bool) {
        
        var cardDictionaryArray = [NSDictionary]()
        for cardNode in cardNodes.sorted(by: { $0.zPosition < $1.zPosition }) {
            let newPositionRelative = CGPoint(x: cardNode.position.x / self.frame.width, y: (cardNode.position.y - self.dividerLine.position.y) / self.frame.width)
            var newPositionTransposed = CGPoint()
            
            switch self.playerPosition {
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
                "p": NSStringFromCGPoint(newPositionTransposed),
                "m": moveToFront,
                "a": animate
                //"zPosition": cardNode.zPosition
            ]
            
            cardDictionaryArray.append(cardDictionary)
        }

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


protocol GameSceneDelegate {
    
    func sendData(data: Data)

}




