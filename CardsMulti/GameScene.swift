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
    let timeToSelectMultipleNodes: TimeInterval = 0.5
    let timeToPopUpMenu: TimeInterval = 0.6
    
    let feedbackGenerator = UIImpactFeedbackGenerator()
    
    var gameType: GameType
    var gameConfig: GameConfig
    var loadSaved: Bool
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var settings = StoredSettings()
    
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
    var lastTouchLocation: CGPoint? = nil
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
    var forceTouchEnabled = false
    
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
    var players: [Player?]?
    var scores = [Score]()
    var scoreLabel : SKLabelNode!
    
    var playersHands = [0, 0, 0, 0]
    
    /// Locations to which cards should snap to if moved to within a close distance
    var snapLocations = [SnapLocation]()
    
    var doubleTapAction: (CardSpriteNode) -> Void = { (_ card) in
        card.moveToFront()
        card.flip(sendPosition: true)
    }
    
    var isGameFinished: () -> Bool = { () in return false }
    
    var gameFinishedAction: (() -> Void)?
    
    // MARK: - Computed properties
    
    /// The common are which all players can see
    var playArea: CGRect {
        return CGRect(x: 0, y: self.frame.height - self.frame.width, width: self.frame.width, height: self.frame.width)
    }
    
    /// The number of connected players
    var numberOfPlayers: Int {
        if self.players == nil {
            return 1
        }
        return self.players!.filter { $0 != nil }.count
    }
    
    // MARK: - Initializers
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience override init(size: CGSize) {
        self.init(size: size, gameType: .freePlay, loadFromSave: true)
    }
    
    convenience init(size: CGSize, loadFromSave: Bool) {
        self.init(size: size, gameType: .freePlay, loadFromSave: loadFromSave)
    }
    
    convenience init(size: CGSize, gameType: GameType) {
        self.init(size: size, gameType: gameType, loadFromSave: true)
    }
    
    init(size: CGSize, gameType: GameType, loadFromSave: Bool) {
        self.gameType = gameType
        self.loadSaved = loadFromSave
        self.gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType) ?? GameConfig(gameType: gameType)
        super.init(size: size)
        
        if (!self.gameConfig.canChangeCardSize && self.settings.cardWidthsPerScreen != self.gameConfig.defaultSettings.cardWidthsPerScreen) {
            self.settings.cardWidthsPerScreen = self.gameConfig.defaultSettings.cardWidthsPerScreen
            self.updateUISettings()
        }
        
        self.gameFinishedAction = { () -> Void in
            print("game finished action")
            self.gameSceneDelegate?.presentAlert(title: "game over".localized, text: nil, actionTitle: "new game".localized, action: { () -> Void in
                self.shuffleAndStackAllCards(sync: true)
            }, cancelAction: nil)
        }
    }
    
    override func sceneDidLoad() {
        self.resetGame(sync: false, loadSaved: self.loadSaved)
        self.lastUpdateTime = 0
    }
    
    // MARK: - Private methods
    
    /**
     Selects multiple cards or rotate single card to 0
     
     - parameter location: location of the touch
     */
    private func didForceOrLongTouch(at location: CGPoint) {
        if #available(iOS 13.0, *) {
            self.feedbackGenerator.impactOccurred(intensity: 1.0)
        } else {
            self.feedbackGenerator.impactOccurred()
        }
        
        self.rotating = false
        self.forceTouchActivated = true
        self.selectMultipleNodesForTouch(touchLocation: location)

        self.forceOrLongTouchAction(at: location)
    }
    
    // MARK: - Public methods
    
    func forceOrLongTouchAction(at location: CGPoint) {
        if self.selectedNodes.count == 0 {
            self.gameSceneDelegate?.presentPopUpMenu(title: String(format: "%d cards".localized, self.selectedNodes.count), withItems: self.popUpMenuItems(at: location), at: location)
        } else if self.selectedNodes.count == 1 {
            self.selectedNodes[0].rotate(to: 0, duration: self.shortDuration, sendPosition: true)
        }
    }
    
    /**
     Returns the number of cards in the area of the player in the specified position
     
     - parameter position: the player's position
     */
    func numberOfCards(inPosition position: Position) -> Int {
        return self.cards(inPosition: position).count
    }
    
    /**
     Returns the set of cards in the specified player's area
     
     - parameter position: position of the player
     */
    func cards(inPosition position: Position?) -> [CardSpriteNode] {
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
        default:
            return self.allCards
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
    
    /**
     Updates the score label
     */
    func updateScoreLabel() {
        if let score = self.scores.first {
            if let scoreLabel = self.scoreLabel {
                scoreLabel.text = score.scoreText
            }
        }
    }
    
    /**
     Resets all of the games scores to zero
     */
    func resetScores() {
        for score in self.scores {
            score.reset()
        }
    }
    
    /**
     Returns pop up menu items for recall of cards from beyond the screen
     */
    func popUpMenuItemsForRecall(at touchLocation: CGPoint) -> [PopUpMenuItem]? {
        if !self.playArea.contains(touchLocation) {
            return nil
        }
        
        var popUpMenuItems = [PopUpMenuItem]()
        for position in Position.allCases.filter({ $0.rawValue > 0 }) {
            if self.numberOfCards(inPosition: position) > 0 {
                let popUpMenuItem = PopUpMenuItem(title: String(format: "recall cards from %@".localized, "\(position)".localized), action: {(_ position: Any?) in
                    if let recallFromPosition = position as? Position {
                        self.recallCards(from: recallFromPosition, to: touchLocation)
                    }
                }, parameter: position)
                popUpMenuItems.append(popUpMenuItem)
            }
        }
        return popUpMenuItems
    }
    
    func popUpMenuItemsForMultipleCardsSelected(at touchLocation: CGPoint) -> [PopUpMenuItem]? {
        var popUpMenuItems = [PopUpMenuItem]()
        
        popUpMenuItems.append(PopUpMenuItem(title: "shuffle".localized, action: {(_: Any?) in
            self.shuffleSelectedCards()
        }, parameter: nil))
        
        popUpMenuItems.append(PopUpMenuItem(title: "stack".localized, action: {(_: Any?) in
            self.stackSelectedCards()
        }, parameter: nil))
        
        popUpMenuItems.append(PopUpMenuItem(title: "fan".localized, action: {(_: Any?) in
            self.fan(cards: self.selectedNodes, faceUp: true)
        }, parameter: nil))
        
        for card in self.selectedNodes {
            if card.faceUp {
                popUpMenuItems.append(PopUpMenuItem(title: "flip face down".localized, action: {(_: Any?) in
                    for card in self.selectedNodes {
                        card.flip(faceUp: false, sendPosition: true)
                    }
                }, parameter: nil))
                break
            }
        }
        
        for card in self.selectedNodes {
            if !card.faceUp {
                popUpMenuItems.append(PopUpMenuItem(title: "flip face up".localized, action: {(_: Any?) in
                    for card in self.selectedNodes {
                        card.flip(faceUp: true, sendPosition: true)
                    }
                }, parameter: nil))
                break
            }
        }
        
        let maxNumberOfCardsToDeal = self.selectedNodes.count / self.numberOfPlayers
        for index in 1...maxNumberOfCardsToDeal {
            popUpMenuItems.append(PopUpMenuItem(title: "\("deal".localized) \(index)", action: {(_: Any?) in
                self.deal(numberOfCards: index)
            }, parameter: nil))
        }
        
        return popUpMenuItems
    }
    
    /**
     Returns pop up menu items for the specified point on the screen
     */
    func popUpMenuItems(at touchLocation: CGPoint) -> [PopUpMenuItem]? {
        if self.selectedNodes.count == 0 {
            return self.popUpMenuItemsForRecall(at: touchLocation)
        } else if selectedNodes.count > 1 {
            return self.popUpMenuItemsForMultipleCardsSelected(at: touchLocation)
        }
        
        return nil
    }

    // MARK: - Game methods
    
    /**
     Saves positions of all cards
     */
    func saveGame() {
        DispatchQueue.global(qos: .background).async {
            GameState.instance.cardNodes = self.allCards
            GameState.instance.scores = self.scores
        }
    }
    
    /**
     Load cards from a saved state or start over with a new deck
     
     - parameter loadSaved: whether to load from a saved state
     */
    func loadCards(fromSaved loadSaved: Bool) {
        let continueGameType = StoredSettings.instance.game == self.gameType.rawValue
        let savedCards = GameState.instance.cardNodes
        if continueGameType && loadSaved && savedCards.count > 0 {
            self.allCards = savedCards
            self.initCards()
            
            for card in self.allCards.sorted(by: { $0.zPosition < $1.zPosition }) {
                if let snapLocationName = card.snapLocationName {
                    let snapLocations = self.snapLocations.filter { $0.name == snapLocationName }
                    if snapLocations.count > 0 {
                        let snapLocation = snapLocations.first
                        let snapShouldFlip = snapLocation?.shouldFlip
                        snapLocation?.shouldFlip = false
                        snapLocation?.snap(card)
                        snapLocation?.shouldFlip = snapShouldFlip ?? false
                    }
                }
            }
            
            self.loadScores()
        } else {
            self.allCards = Global.newShuffledDeck(name: "deck", settings: StoredSettings.instance)
            self.initCards()
            self.shuffleAndStackAllCards(sync: false)
        }
    }
    
    /**
     Loads game scores from saved state
     */
    func loadScores() {
        let savedScores = GameState.instance.scores
        if savedScores.count > 0 {
            self.scores = savedScores
            self.updateScoreLabel()
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
    
    fileprivate func resetNodes() {
        self.removeAllChildren()
        
        connectionLabel = SKLabelNode(text: "Connections: ")
        connectionLabel.fontColor = UIColor.green
        connectionLabel.fontSize = 15
        connectionLabel.fontName = "Helvetica"
        connectionLabel.position = CGPoint(x: connectionLabel.frame.width / 2, y: self.frame.height - connectionLabel.frame.height / 2 - border)
        connectionLabel.zPosition = 100
        self.initDividerLine(hidden: false)
    }
    
    /**
     Resets the scene, re-initializes all nodes and prepares a new shuffled deck
     
     - parameters:
        - sync: whether to synchronize connected devices to this device after the execution
        - loadSaved: whether to load the save game state
     */
    func resetGame(sync: Bool, loadSaved: Bool = false) {
        self.resetNodes()
        
        self.loadCards(fromSaved: loadSaved)
 
    }
    
    /**
     Resets the scene and re-initializes all nodes, but doesn't position the new cards
     */
    func resetCards() {
        self.resetNodes()
        self.allCards = Global.newShuffledDeck(name: "deck", settings: StoredSettings.instance)
        self.initCards()
    }
    
    /**
     Shuffles all cards and places the shuffled deck in the middle of the playing area
     
     - parameter sync: whether to synchronize with other devices after execution
     */
    func shuffleAndStackAllCards(sync: Bool) {
        Global.shuffle(&self.allCards)
        
        for cardNode in self.allCards {
            cardNode.zRotation = 0
            cardNode.moveToFront()
        }
        
        self.allCards.stack(atPosition: self.playArea.center, flipEachCard: true, faceUp: false, reverseStack: false, sendPosition: sync, animateReceiver: true, delegate: self)
    }
    
    /**
     Default deal method to be overridden by subclasses
     */
    func deal() {
        
    }
    
    /**
     Deal the specified number of cards into each of the connected players' areas
     
     - parameter numberOfCards: number of cards to deal to each player
     */
    func deal(numberOfCards: Int) {
        let _ = self.deal(fromCards: self.selectedNodes, numberOfCards: numberOfCards)
        self.deselectNodeForTouch()
    }
    
    /**
     Deals the specified number of cards from the specified set of cards to each connnected player
     
     - parameters:
        - cards: the set of cards to deal from
        - numberOfCards: the number of cards to deal to each player
     
     - returns: a tuple containing remaining cards and the duration the deal is going to take
     */
    func deal(fromCards cards: [CardSpriteNode], numberOfCards: Int) -> (remainingCards: [CardSpriteNode], duration: Double) {
        var cardsToDeal = Array(cards.sorted { $0.zPosition > $1.zPosition }.prefix(upTo: numberOfCards * self.numberOfPlayers))
        let remainingCards = Array(Set(cards).subtracting(cardsToDeal))
        let duration = Double(numberOfCards * self.numberOfPlayers) * self.resetDuration
        
        DispatchQueue.global(qos: .default).async {
            for _ in 1...numberOfCards {
                for direction in [Position.left, Position.top, Position.right, Position.bottom] {
                    let nextPositionToDealTo = direction.positionTo(self.playerPosition)
                    
                    if self.players?[nextPositionToDealTo.rawValue] != nil {
                        cardsToDeal = self.deal(toPosition: direction, fromCards: cardsToDeal)
                        usleep(useconds_t(self.resetDuration * 1000000))
                    }
                }
            }
        }
        
        return (remainingCards, duration)
    }
    
    /**
     Deal one card from the top of the passed pile to the specified position
     
     - parameters:
        - position: player's position to deal the card to
        - cards: set of cards to deal from
     
     - returns: Set of cards without the dealt card
     */
    func deal(toPosition position: Position, fromCards cards: [CardSpriteNode]) -> [CardSpriteNode] {
        if cards.count > 0 {
            //  select top card
            var cardsSorted = cards.sorted { $0.zPosition > $1.zPosition }
            let cardToDeal = cardsSorted.first
            // deal the card to somewhere in the area
            let newLocation = self.randomLocationForPlayer(in: position)
            
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
     Spreads cards randomly around the specified area
     
     - parameters:
        - cardNodes: cards to spread
        - centerPoint: centre point around which to spread the cards
        - radius: the radius of the area from the centre poit
        - flipFaceUp: whether to flip the cards face up or down
     */
    func pool(cardNodes: [CardSpriteNode], centeredIn centerPoint: CGPoint, withRadius radius: CGFloat, flipFaceUp: Bool) {
        for card in cardNodes {
            let angle = CGFloat(Int.random(in: -179...180)).degreesToRadians
            let distance = CGFloat(Int.random(in: 0...Int(radius)))
            let rotation = CGFloat(Int.random(in: -89...90)).degreesToRadians
            
            let point = CGPoint(x: centerPoint.x, y: centerPoint.y + distance).rotateAbout(point: centerPoint, byAngle: angle)
            
            card.moveAndFlip(to: point, rotateToAngle: rotation, faceUp: flipFaceUp, duration: self.resetDuration, sendPosition: true, animateReceiver: true)
        }
    }
    
    
    /**
     Returns a random location weighted towards the centre in the specified player's area
     
     - parameter position: position of the player
     
     - returns: coordinates of the random location
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
            //self.stack(cards: cardsSorted, at: topCardLocation)
            
            self.selectedNodes.stack(atPosition: topCardLocation, sendPosition: true, animateReceiver: true, delegate: self)
            
            self.deselectNodeForTouch()
        }
    }
    
    /**
     Moves cards from specified player position to the specified location.
     If the position is null, moves all cards. If the location is null, cards are moved to the centre of the play area.
     - parameter position: position to move cards from
     - parameter location: location to move cards to
     */
    func recallCards(from position: Position?, to location: CGPoint?) {
        self.forceTouchActivated = false
        let cards = self.cards(inPosition: position)
        cards.stack(atPosition: location ?? self.playArea.center, sendPosition: true, delegate: self)
    }
    
    /**
     Separates the specified set of cards into two stacks
     
     - parameter cards: the set of cards to cut
     */
    func cut(cards: [CardSpriteNode]) {
        if cards.count > 1 {
            let cardsSorted = cards.sorted { $0.zPosition > $1.zPosition }
            let originalPosition  = cardsSorted.first?.position
            var position1 = CGPoint(x: (originalPosition?.x)! - (cardsSorted.first?.frame.size.width)! / 2 - self.xOffset, y: (originalPosition?.y)!)
            var position2 = CGPoint(x: (originalPosition?.x)! + (cardsSorted.first?.frame.size.width)! / 2 + self.xOffset, y: (originalPosition?.y)!)
            
            if position1.x < (cardsSorted.first?.frame.width)! / 2 + self.xOffset {
                position1.x = (cardsSorted.first?.frame.width)! / 2 + self.border
                position2.x = position1.x + (cardsSorted.first?.frame.width)! + 2 * self.xOffset
            } else if position2.x > self.frame.width - (cardsSorted.first?.frame.width)! / 2 - self.xOffset {
                position2.x = self.frame.width - (cardsSorted.first?.frame.width)! / 2 - self.border
                position1.x = position2.x - (cardsSorted.first?.frame.width)! - 2 * self.xOffset
            }
            
            let halfIndex: Int = cardsSorted.count / 2
            let stack1 = Array(cardsSorted.prefix(upTo: halfIndex))
            let stack2 = Array(cardsSorted.suffix(from: halfIndex))
            
            stack1.stack(atPosition: position1, sendPosition: true, animateReceiver: true, delegate: self)
            stack2.stack(atPosition: position2, sendPosition: true, animateReceiver: true, delegate: self)
        }
    }
    
    func stoppedCutting(touchLocation: CGPoint) {
        print ("cutting \(self.cutStartPosition) -> \(touchLocation)")
        
        let origin = CGPoint(x: min(touchLocation.x, self.cutStartPosition.x), y: min(touchLocation.y, self.cutStartPosition.y))
        let width = abs(touchLocation.x - self.cutStartPosition.x)
        let height = abs(touchLocation.y - self.cutStartPosition.y)
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
                
                if let snapLocation = touchedCardNode.snapLocation {
                    //if snapLocation.movableConditionMet(touchedCardNode) {
                        self.selectedNodes = snapLocation.selectedCardsWhenTouched(touchedCardNode)
                        if let tapAction = snapLocation.tapAction {
                            tapAction(touchedCardNode)
                        }
                    //}
                } else {
                    self.selectedNodes = [touchedCardNode]
                }

                if tapCount > 1 && self.canDoubleTap {
                    // this is the second tap
                    if let snapLocation = touchedCardNode.snapLocation {
                        // if the card is snapped to a location, perform that location's double tap action
                        print("performing double tap action for \(snapLocation.name)")
                        snapLocation.doubleTapAction(snapLocation)
                    } else {
                        // otherwise, perform the scene's double tap action
                        print("performing scene double tap action")
                        self.doubleTapAction(touchedCardNode)
                    }
                    
                    self.endTouchesReset()
                } else if self.gameConfig.canRotateCards && touchedCardNode.pointInCorner(touchLocation) {
                    // touched in the corner of the card
                    // select for rotation
                    self.rotating = true
                }
                
                self.canDoubleTap = true
                self.sendPosition(of: self.selectedNodes, moveToFront: false, animate: false)
            }
        } else {
            
            // tap action on empty snap locations
            for snapLocation in self.snapLocations {
                if snapLocation.snapRect.contains(touchLocation) {
                    if let tapAction = snapLocation.tapAction {
                        tapAction(nil)
                    }
                }
            }
        }
    }
    
    /**
     Selects multiple cards at the touch location
     
     - parameter touchLocation: location of the touch
     */
    func selectMultipleNodesForTouch(touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is CardSpriteNode {
            let touchedCardNode = touchedNode as! CardSpriteNode
            
            if let snapLocation = touchedCardNode.snapLocation {
                // if the card is snapped, select all movable cards from the snap location
                self.selectedNodes = snapLocation.movableCardNodes()
            } else {
                // otherwise select cards normally
                self.selectedNodes = touchedCardNode.touching(cards: self.allCards)
            }
            
            for cardNode in self.selectedNodes.sorted(by: { $0.zPosition < $1.zPosition }) {
                cardNode.pop()
                cardNode.moveToFront()
            }
            
            print("force touched to drag cards: ", terminator: "")
            Global.displayCards(self.selectedNodes)
            
            self.sendPosition(of: self.selectedNodes, moveToFront: true, animate: false)
        }
    }
    
    /**
     Removes the specified cards from snap locations
     
     - parameter cardNodes: the cards to unsnap
     */
    func unSnap(_ cardNodes: [CardSpriteNode]) {
        DispatchQueue.global(qos: .default).async {
            for card in cardNodes {
                if let snapLocation = card.snapLocation {
                    if snapLocation.unsnapWhenMoved {
                        snapLocation.unSnap(cards: [card])
                    }
                    
                    if snapLocation.snapBack {
                        card.snapBackToLocation = snapLocation
                    }
                }
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
     Perform reset actions after touches ended
     */
    func endTouchesReset() {
        print("endTouchesReset")
        self.forceTouchActivated = false
        self.rotating = false
        self.cardsMoved = false
        self.deselectNodeForTouch()
        self.lastTouchLocation = nil
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
        cards.stack(atPosition: topCardPosition!, sendPosition: true, animateReceiver: true, delegate: self)
 
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
            print("touchesBegan tapCount \(t.tapCount)")
            
            self.feedbackGenerator.prepare()
            
            self.selectNodeForTouch(touchLocation: t.location(in: self), tapCount: t.tapCount)
            
            self.firstTouchLocation = t.location(in: self)
            self.touchesBeganTimestamp = t.timestamp
            self.lastTouchTimestamp = t.timestamp
            self.lastTouchMoveTimestamp = t.timestamp
            self.lastTouchLocation = t.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //print("touchesMoved tapCount \(t.tapCount)")
 
            let currentPosition = t.location(in: self)
            let previousPosition = t.previousLocation(in: self)
            let transformation = CGPoint(x: currentPosition.x - previousPosition.x, y: currentPosition.y - previousPosition.y)
            
            // determine speed of last move
            let timeInterval = t.timestamp - self.lastTouchTimestamp
            self.setMovingSpeed(startPosition: previousPosition, endPosition: currentPosition, time: timeInterval)
            
            if self.forceTouchEnabled {
                if t.force / t.maximumPossibleForce >= self.forceTouchRatio {
                    print("Force or long touch activated")
                    if !self.forceTouchActivated {
                        self.didForceOrLongTouch(at: currentPosition)
                    }
                }
            }
            
            if transformation.isNonZero {
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
                    
                }
            }
            
            self.lastTouchTimestamp = t.timestamp
            self.lastTouchLocation = t.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchLocation = nil
        for t in touches {
            print("touchesEnded tapCount \(t.tapCount)")
            
            if t.tapCount > 1 {
                return
            }
            
            //self.forceTouchActivated = false
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
                    print("will call self.snap")
                    self.snap(self.selectedNodes)
                }
               
                self.currentMovingSpeed = CGVector()
                self.currentRotationSpeed = CGFloat()
                self.lastTouchTimestamp = 0.0
                self.lastTouchMoveTimestamp = 0.0
                let touchLocation = t.location(in: self)
                
                // pop up cotextual menu, if multiple cards were selected
                // and the cards were't being moved
                // and less that a certain time interval elapsed since touches began
                // should contain: deal, shuffle
                let timeSinceTouchesBegan = t.timestamp - self.touchesBeganTimestamp
                if self.selectedNodes.count > 1 &&
                    self.firstTouchLocation == touchLocation && self.forceTouchActivated &&
                    (timeSinceTouchesBegan < self.timeToPopUpMenu || !self.forceTouchEnabled) {
                    self.forceTouchActivated = false
                    
                    self.gameSceneDelegate?.presentPopUpMenu(title: String(format: "%d cards".localized, self.selectedNodes.count), withItems: self.popUpMenuItems(at: touchLocation), at: touchLocation)
                    return
                }
                
            }
        }
                
        self.endTouchesReset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endTouchesReset()
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
        
        if !forceTouchEnabled {
            if let touchLocation = self.lastTouchLocation, !forceTouchActivated && lastTouchMoveTimestamp != 0.0 && currentTime - lastTouchMoveTimestamp >= timeToSelectMultipleNodes {
                print("didForceOrLongTouch")
                self.didForceOrLongTouch(at: touchLocation)
            }
        }
    }
    
    // MARK: - Network sync methods
    
    /**
     Returns data for synchronising settigs and all card positions
     */
    func syncSettingsAndGameData() -> Data? {
        let settingsData = RequestData(withType: .settings, andDictionary: StoredSettings.instance.settingsDictionary)
        let gameData = RequestData(withType: .game, andArray: Global.cardDictionaryArray(with: self.allCards, playerPosition: self.playerPosition, width: self.frame.width, yOffset: self.dividerLine.position.y, moveToFront: true, animate: false))
        
        let requestData = [settingsData, gameData]
        do {
            let encodedData = try requestData.encodedData()
            return encodedData
        } catch {
            return nil
        }
    }
    
    func syncSceneToMe() {
        self.sendPosition(of: self.allCards, moveToFront: true, animate: false)
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
            let requestData = RequestData(withType: .game, andArray: [cardDictionary])
            if let encodedData = try requestData.encodedData() {
                self .gameSceneDelegate?.sendData(data: encodedData, type: .game)
            }
        } catch {
            print("Error serializing json data: \(error)")
        }
    }
    
    func sendPosition(of cardNodes: [CardSpriteNode], moveToFront: Bool, animate: Bool) {
        
        let cardDictionaryArray = Global.cardDictionaryArray(with: cardNodes, playerPosition: self.playerPosition, width: self.frame.width, yOffset: self.dividerLine.position.y, moveToFront: moveToFront, animate: animate)

        do {
            let gameData = RequestData(withType: .game, andArray: cardDictionaryArray)
            if let requestData = try gameData.encodedData() {
                self.gameSceneDelegate!.sendData(data: requestData, type: .game)
            }
        } catch {
            print("Error serializing json data: \(error)")
        }

    }
    
    /**
     Sends the z positions of all cards to sychroize vertical order
     */
    func sendZPositions() {
        print("Sending z positions")
        
        let cardsSorted = self.allCards.sorted { $0.zPosition < $1.zPosition }
        let zPositionsArray = cardsSorted.map { $0.card?.symbol }
                
        do {
            let requestData = RequestData(withType: .game, andArray: zPositionsArray as Array<Any>)
            if let encodedData = try requestData.encodedData() {
                self.gameSceneDelegate?.sendData(data: encodedData, type: .game)
            }
        } catch {
            print("failed to serialize zposition data")
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
        if settings.soundOn && !self.hasActions() {
            self.run(self.moveSound)
        }
    }
    
    func makeFlipSound() {
        if settings.soundOn && !self.hasActions() {
            self.run(self.flipSound)
        }
    }
    
    func snap(_ cardNodes: [CardSpriteNode]) {
        print("scene snap")
        DispatchQueue.global(qos: .default).async {
            var snappedToNewLocation = false
            let cardNodesSorted = cardNodes.sorted { $0.zPosition < $1.zPosition }
            if let bottomCard = cardNodesSorted.first {
                for snapLocation in self.snapLocations {
                    if snapLocation.shouldSnap(cardNode: bottomCard) {
                        if let currentSnapLocation = bottomCard.snapLocation {
                            currentSnapLocation.unSnap(cards: cardNodes)
                        }
                        
                        if let previousSnapLocation = bottomCard.snapBackToLocation {
                            previousSnapLocation.unSnap(cards: cardNodes)
                        }
                        snapLocation.snap(cardNodes)
                        snappedToNewLocation = true
                        break
                    }
                }
                
                if let snapBackToLocation = bottomCard.snapBackToLocation {
                    if !snappedToNewLocation && snapBackToLocation.snapBack {                    
                        snapBackToLocation.snap(cardNodes)
                    }
                }
            }
        }        
    }
    
    func moveCompleted() {
        self.saveGame()
        
        DispatchQueue.global(qos: .background).async {
            if self.isGameFinished(), let action = self.gameFinishedAction {
                DispatchQueue.global(qos: .default).async {
                    action()
                }
            }
        }
        
    }
}

// MARK: - Protocol GameSceneDelegate

protocol GameSceneDelegate {
    
    func sendData(data: Data, type dataType: WsDataType)

    func peers() -> [MCPeerID?]
    
    func presentPopUpMenu(title: String?, withItems items: [PopUpMenuItem]?, at location: CGPoint)
    
    func updatePlayer(numberOfCards: Int, inPosition position: Position)
    
    func presentAlert(title: String?, text: String?, actionTitle: String, action: @escaping (() -> Void), cancelAction: (() -> Void)?)
}




