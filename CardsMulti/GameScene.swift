//
//  GameScene.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let numberOfCards = 1
    let minRank = 2
    let border: CGFloat = 10.0
    let resetDuration = 0.5
    let verticalHeight = 0.3
    let cornerTapSize: CGFloat = 50.0
    let xOffset: CGFloat = 20.0
    let yOffset: CGFloat = 5.0
    let xPeek: CGFloat = 20.0
    let yPeek: CGFloat = 20.0

    
    let connectionService = ConnectionServiceManager()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    var connectionLabel : SKLabelNode!

    var selectedNode = CardSpriteNode()
    var lastSelectedNode = CardSpriteNode()
    var movingSpeed = CGVector()
    var lastTouchTimestamp = 0.0
    
    var allCards = [CardSpriteNode]()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        connectionService.delegate = self

        connectionLabel = SKLabelNode(text: "Connections: ")
        connectionLabel.fontColor = UIColor.green
        connectionLabel.fontSize = 20
        connectionLabel.position = CGPoint(x: connectionLabel.frame.width / 2, y: connectionLabel.frame.height / 2)
        self.addChild(connectionLabel)
        
        resetGame()
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
    }
    
    func resetGame() {
        //allCards = newShuffledDeck(minRank: minRank, numberOfCards: numberOfCards, name: "deck")
        let newCard = CardSpriteNode(card: Card(suit: Suit.spades, rank: Rank.queen), name: "deck")
        allCards.append(newCard)
        for (cardNumber,cardNode) in allCards.enumerated() {
            cardNode.delegate = self
            //cardNode.texture = cardNode.backTexture
            cardNode.faceUp = true
            cardNode.selectable = true
            cardNode.zPosition = CGFloat(0 - cardNumber)
            let cardOffset = CGFloat(Double(cardNumber) * verticalHeight)
            cardNode.position = CGPoint(x: cardNode.frame.size.width / 2 + CGFloat(border) + cardOffset, y: self.frame.size.height / 2 - CGFloat(border) - yPeek - cardNode.frame.size.height / 2 - cardOffset)
            self.addChild(cardNode)
            lastSelectedNode = cardNode
        }

    }
    
    func selectNodeForTouch(touchLocation: CGPoint, tapCount: Int) {
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is CardSpriteNode {
            
            // select card to move
            let touchedCardNode = touchedNode as! CardSpriteNode
            if touchedCardNode.selectable {
                if !selectedNode.isEqual(touchedCardNode) {
                    selectedNode = touchedCardNode
                    selectedNode.moveToFront()
                }
                
                if tapCount > 1 {
                    // this is the second tap - flip the card
                    selectedNode.flip()
                }
            }
        }
    }

    func setMovingSpeed(startPosition: CGPoint, endPosition: CGPoint, time: Double) {
        movingSpeed.dx = (endPosition.x - startPosition.x) / CGFloat(time)
        movingSpeed.dy = (endPosition.y - startPosition.y) / CGFloat(time)
    }
    
    func deselectNodeForTouch() {
        selectedNode = CardSpriteNode()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        for t in touches {
            selectNodeForTouch(touchLocation: t.location(in: self), tapCount: t.tapCount)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let currentPosition = t.location(in: self)
            let previousPosition = t.previousLocation(in: self)
            let transformation = CGPoint(x: currentPosition.x - previousPosition.x, y: currentPosition.y - previousPosition.y)
            //let timeInterval = t.timestamp - lastTouchTimestamp
            //setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
            
            lastTouchTimestamp = t.timestamp
            if selectedNode.selectable {
                selectedNode.move(transformation: transformation)
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if selectedNode.selectable {
                let currentPosition = t.location(in: self)
                let previousPosition = t.previousLocation(in: self)
                let timeInterval = t.timestamp - lastTouchTimestamp
                setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
                //print("touches ended")
                selectedNode.stopMoving(startSpeed: movingSpeed)
                lastTouchTimestamp = 0.0
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
    }
}


/*
 ConnectionServiceManagerDelegate
 */

extension GameScene : ConnectionServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ConnectionServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionLabel.text = "Connections: \(connectedDevices)"
            self.connectionLabel.position = CGPoint(x: self.connectionLabel.frame.width / 2, y: self.connectionLabel.frame.height / 2)
        }
    }
    
    func receivedData(manager: ConnectionServiceManager, data: Data) {
        //get CGPoint from Data
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        let newPosition = CGPointFromString(str)
        lastSelectedNode.position = newPosition
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
    
    func sendPosition(of cardNode: CardSpriteNode) {
        let newPositionString = NSStringFromCGPoint(cardNode.position)
        let newPositionData = newPositionString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        connectionService.sendData(data: newPositionData)
    }
}

