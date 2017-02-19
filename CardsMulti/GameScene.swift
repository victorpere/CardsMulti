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
    let verticalHeight = 0.3
    let cornerTapSize: CGFloat = 50.0
    let xOffset: CGFloat = 20.0
    let yOffset: CGFloat = 5.0
    let xPeek: CGFloat = 20.0
    let yPeek: CGFloat = 20.0
    let buffer: CGFloat = 100.0
    let forceTouchRatio: CGFloat = 0.9
    let timeToSelectMultipleNodes: TimeInterval = 2
    
    //let connectionService = ConnectionServiceManager()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //connectionService.delegate = self

        
        connectionLabel = SKLabelNode(text: "Connections: ")
        connectionLabel.fontColor = UIColor.green
        connectionLabel.fontSize = 15
        connectionLabel.fontName = "Helvetica"
        connectionLabel.position = CGPoint(x: connectionLabel.frame.width / 2, y: connectionLabel.frame.height / 2)
        connectionLabel.zPosition = 100
        self.addChild(connectionLabel)
        
        
        //var points = [CGPoint(x: 0, y: self.frame.height - self.frame.width), CGPoint(x: self.frame.width, y: self.frame.height - self.frame.width)]
        var points = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        dividerLine = SKShapeNode(points: &points, count: points.count)
        dividerLine.position = CGPoint(x: 0, y: self.frame.height - self.frame.width)
        dividerLine.zPosition = -100
        self.addChild(dividerLine)
        
        self.resetGame()
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
    }
    
    func resetGame() {
        allCards = newShuffledDeck(minRank: minRank, numberOfCards: numberOfCards, name: "deck")
        /*
        let newCard = CardSpriteNode(card: Card(suit: Suit.spades, rank: Rank.queen), name: "deck")
        allCards.append(newCard)
        let newCard2 = CardSpriteNode(card: Card(suit: Suit.diamonds, rank: .six), name: "deck")
        allCards.append(newCard2)
        */
        
        for cardNode in allCards {
            self.addChild(cardNode)
        }

        self.resetCards(sync: false)
    }
    
    func resetCards(sync: Bool) {
        shuffle(&allCards)
        
        for cardNode in allCards {
            cardNode.delegate = self
            cardNode.flip(faceUp: false, sendPosition: false)
            cardNode.selectable = true
            //cardNode.zPosition = CGFloat(0 - cardNumber)
            cardNode.moveToFront()
            //let cardOffset = CGFloat(Double(cardNumber) * verticalHeight)
            cardNode.position = CGPoint(x: self.frame.midX, y: self.dividerLine.position.y + self.frame.width / 2)
            //cardNode.position = CGPoint(x: cardNode.frame.size.width / 2 + CGFloat(border) + cardOffset, y: self.frame.size.height - CGFloat(border) - yPeek - cardNode.frame.size.height / 2 - cardOffset)

            /*
            if sync {
                cardNode.delegate!.sendPosition(of: [cardNode])
            }
             */
        }
        if sync {
            self.sendPosition(of: allCards)
        }
    }
    
    func resetHand() {
        let usableWidth = self.frame.size.width - (border * 2)

        let hand = allCards.filter { $0.position.y < self.dividerLine.position.y }
        
        for (nodeNumber, cardNode) in hand.enumerated() {
            
            let node_x = ((usableWidth - cardNode.frame.size.width) / CGFloat(hand.count)) * CGFloat(nodeNumber)
            let newPosition = CGPoint(x: cardNode.frame.size.width / 2 + node_x + border, y: cardNode.frame.size.height / 2 + border)
            cardNode.moveToFront()
            cardNode.moveAndFlip(to: newPosition, faceUp: true, duration: self.resetDuration)
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
            }
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
            if t.location(in: self).x < cornerTapSize  && t.location(in: self).y < cornerTapSize {
                // bottom left corner
                self.resetHand()
            } else if t.location(in: self).x > self.frame.width - cornerTapSize && t.location(in: self).y < cornerTapSize {
                // bottom right corner
                resetCards(sync: true)
            } else {
                selectNodeForTouch(touchLocation: t.location(in: self), tapCount: t.tapCount)
            }
            
            lastTouchTimestamp = t.timestamp
            lastTouchMoveTimestamp = t.timestamp
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            print("touches moved at \(t.location(in: self)) at \(t.timestamp)")
 
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
                        self.sendPosition(of: selectedNodes)
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
}


/*
 ConnectionServiceManagerDelegate
 */

extension GameScene : ConnectionServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ConnectionServiceManager, connectedDevices: [MCPeerID]) {
        OperationQueue.main.addOperation {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionLabel.text = "Connections: \(connectedDevicesNames)"
            self.connectionLabel.position = CGPoint(x: self.connectionLabel.frame.width / 2, y: self.connectionLabel.frame.height / 2)
            
            if connectedDevices.count > 0 {
                var allDevices = [self.myPeerId]
                allDevices.append(contentsOf: connectedDevices)
                allDevices.sort { $0.hashValue < $1.hashValue }
                
                print("Syncing with \(allDevices.first?.displayName)")
                if self.myPeerId == allDevices.first {
                
                    // reset deck and sync
                    //self.resetCards(sync: true)
                    
                    // sync other peer(s) to one device
                    self.sendPosition(of: self.allCards)
                }
            }
        }
    }
    
    func receivedData(manager: ConnectionServiceManager, data: Data) {
        
        do {
            let cardDictionaryArray = try JSONSerialization.jsonObject(with: data) as! NSArray
            
            for cardDictionaryArrayElement in cardDictionaryArray {
                let cardDictionary = cardDictionaryArrayElement as! NSDictionary
                
                let cardSymbol = cardDictionary["c"] as! String
                let cardNode = allCards.filter { $0.card?.symbol() == cardSymbol }.first

                let newPositionRelative = CGPointFromString(cardDictionary["p"] as! String)
                let newPosition = CGPoint(x: newPositionRelative.x * self.frame.width, y: newPositionRelative.y * self.frame.height)
                let newPositionInverted = CGPoint(x: self.frame.width - newPosition.x, y: self.frame.height - newPosition.y + self.dividerLine.position.y)
            
                cardNode?.flip(faceUp: cardDictionary["f"] as! Bool, sendPosition: false)
                //cardNode?.zPosition = cardDictionary["zPosition"] as! CGFloat
                cardNode?.moveToFront()
                cardNode?.position = newPositionInverted
            }
        } catch {
            print("Error deserializing json data \(error)")
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
    
    func sendPosition(of cardNodes: [CardSpriteNode]) {
        
        var cardDictionaryArray = [NSDictionary]()
        for cardNode in cardNodes {
            let newPositionRelative = CGPoint(x: cardNode.position.x / self.frame.width, y: cardNode.position.y / self.frame.height)

            let cardDictionary: NSDictionary = [
                "c": (cardNode.card?.symbol())! as String,
                "f": cardNode.faceUp,
                "p": NSStringFromCGPoint(newPositionRelative),
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
}


protocol GameSceneDelegate {
    
    func sendData(data: Data)

}




