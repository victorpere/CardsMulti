//
//  FreeCell.swift
//  CardsMulti
//
//  Created by Victor on 2021-07-21.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import GameKit

/// Subclass of GameScene for playing single player FreeCell
class FreeCell : GameScene {
    
    // MARK: - Constants
    
    /// Additional margin at the top
    let topMargin: CGFloat = 50
    
    /// Initial vertical offset of cards in the tableau
    let initialTableauOffset: CGFloat = -25
    
    /// Vertical offset for the tableau for face up cards
    let tableauOffset: CGFloat = -30
    
    /// Duration to move a card to its starting postion in seconds
    let dealDuration = 0.1
    
    // MARK: - Properties
    
    var tableauLocations = [SnapLocation]()
    var foundations = [SnapLocation]()
    var cells = [SnapLocation]()
    
    // MARK: - Computed properties

    /// Current game score
    var score: Int {
        var score = -52
        for foundation in self.foundations {
            score += 3 * foundation.snappedCards.count
        }
        return score
    }
    
    /// Number of cards that can be moved at the same time
    var numberOfCardsCanMove: Int {
        let m = self.tableauLocations.filter { $0.snappedCards.count == 0 }.count
        let n = self.cells.filter { $0.snappedCards.count == 0 }.count
        
        return Int(pow(2, Double(m))) * (n + 1)
    }
    
    // MARK: - Initializers
    
    init(size: CGSize, loadFromSave: Bool) {
        super.init(size: size, gameType: .freeCell, loadFromSave: loadFromSave)
        
        self.doubleTapAction = { (_ card) in
            for foundation in self.foundations {
                if foundation.isSnappable(card) {
                    if let snapLocation = card.snapLocation {
                        snapLocation.unSnap(cards: [card])
                    }
                    foundation.snap(card)
                    return
                }
            }
        }
        
        self.isGameFinished = { () -> Bool in
            for card in self.allCards {
                if card.snapLocation === self.foundations[0] ||
                    card.snapLocation === self.foundations[1] ||
                    card.snapLocation === self.foundations[2] ||
                    card.snapLocation === self.foundations[3] {
                    continue
                }
                return false
            }
            return true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - GameScene override methods
    
    override func resetGame(sync: Bool, loadSaved: Bool = false) {
        self.removeAllChildren()
        
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.fontColor = UIColor.green
        self.scoreLabel.fontSize = 15
        self.scoreLabel.fontName = "Helvetica"
        self.scoreLabel.position = CGPoint(x: self.border, y: self.frame.height - self.border)
        self.scoreLabel.zPosition = 100
        self.scoreLabel.horizontalAlignmentMode = .left
        self.scoreLabel.verticalAlignmentMode = .top
        self.addChild(self.scoreLabel)
        
        if self.scores.count == 0 {
            let score = Score(peerId: self.myPeerId, name: "RunningScore", gameType: self.gameType)
            score.label = self.scoreLabel
            self.scores.append(score)
        }
        
        self.snapLocations.removeAll()
        self.foundations.removeAll()
        self.tableauLocations.removeAll()
        
        let snapLocationSize = CGSize(width: self.cardWidth, height: self.cardHeight)
        
        // Cells
        for col in 1...4 {
            let location = CGPoint(x: self.margin * CGFloat(col) + self.cardWidth * CGFloat(col) - self.cardWidth / 2, y: self.frame.height - self.cardWidth - self.margin - self.topMargin)
            let cell = SnapLocation(location: location, snapSize: snapLocationSize)
            cell.name = "Cell \(col)"
            cell.maxCards = 1
            cell.snapBack = true
            
            cell.doubleTapAction = { (_ cell) in
                if let topCard = cell.topCard {
                    for foundation in self.foundations {
                        if foundation.isSnappable(topCard) {
                            cell.unSnap(cards: [topCard])
                            foundation.snap(topCard)
                            return
                        }
                    }
                }
            }
            
            cell.selectedCardsWhenTouched = { (_ touchedCard) in
                touchedCard.moveToFront()
                return [touchedCard]
            }
            
            self.cells.append(cell)
            self.snapLocations.append(cell)
        }
        
        // Foundations
        for col in 1...4 {
            let location = CGPoint(x: self.frame.width - self.margin * CGFloat(col) - self.cardWidth * CGFloat(col-1) - self.cardWidth / 2, y: self.frame.height - self.cardWidth - self.margin - self.topMargin)
            let foundation = SnapLocation(location: location, snapSize: snapLocationSize)
            foundation.name = "Foundation \(col)"
            foundation.xOffset = CGFloat(self.verticalHeight)
            foundation.yOffset = CGFloat(self.verticalHeight)
            foundation.snapBack = true
            
            foundation.doubleTapAction = { (_) in }
            
            // conditions for adding cards to the foundations
            foundation.isSnappable = { (_ card) in
                if let topFoundationCard = foundation.topCard {
                    return topFoundationCard.card.suit == card.card.suit && (topFoundationCard.card.rank.rawValue + 1 == card.card.rank.rawValue || (topFoundationCard.card.rank == Rank.ace && card.card.rank == Rank.two))
                }
                
                return card.card.rank == Rank.ace
            }
            
            // top car in the foudation is movable
            foundation.isMovable = { (_ card) in
                return card == foundation.topCard
            }
            
            foundation.snapAction = { (_) in
                if let score = self.scores.first {
                    score.score += 3
                    self.updateScoreLabel()
                }
            }
            
            foundation.unsnapAction = { (cards) in
                if let score = self.scores.first {
                    score.score -= Double(3 * cards.count)
                    self.updateScoreLabel()
                }
            }
            
            self.snapLocations.append(foundation)
            self.foundations.append(foundation)
        }
        
        // Tableau
        for col in 0...7 {
            let location = CGPoint(x: self.cardWidth / 2 + self.margin * CGFloat(col + 1) + self.cardWidth * CGFloat(col), y: self.frame.height - self.cardWidth * 3 - self.margin - self.topMargin)
            let tableau = SnapLocation(location: location, snapSize: snapLocationSize)
            tableau.name = "Tableau \(col + 1)"
            tableau.yOffset = self.initialTableauOffset
            tableau.snapAreaIncludesCards = true
            tableau.shouldFlip = true
            tableau.faceUp = true
            tableau.unsnapWhenMoved = false
            tableau.snapBack = true
            
            // conditions for adding cards to a tableau
            tableau.isSnappable = { (_ card) in
                if tableau.snappedCards.count == 0 {
                    return true
                }
                
                if let topCard = tableau.topCard {
                    return topCard.card.suit.color != card.card.suit.color && topCard.card.rank.rawValue == card.card.rank.rawValue + 1
                }
                
                return false
            }
            
            // double tap moves the car to a foundation if possible
            tableau.doubleTapAction = { (_ tableau) in
                if let topCard = tableau.topCard {
                    for foundation in self.foundations {
                        if foundation.isSnappable(topCard) {
                            tableau.unSnap(cards: [topCard])
                            foundation.snap(topCard)
                            return
                        }
                    }
                }
            }
            
            // when a card in the tableau is touched, select the card and all cards on top of it
            tableau.selectedCardsWhenTouched = { (_ touchedCard) in
                guard let topCard = tableau.topCard else { return [] }
                if touchedCard == topCard {
                    topCard.moveToFront()
                    return [topCard]
                }
                
                var selectedCards = [topCard]
                let maxMovableCards = min(self.numberOfCardsCanMove, tableau.snappedCards.count)
                
                let sortedCards = tableau.snappedCards.sorted(by: { $0.zPosition > $1.zPosition })
                if (maxMovableCards > 1) {
                    for i in 1...maxMovableCards - 1 {
                        let thisCard = sortedCards[i]
                        let previousCard = sortedCards[i-1]
                        
                        if thisCard.card.suit.color != previousCard.card.suit.color &&
                            thisCard.card.rank.rawValue == previousCard.card.rank.rawValue + 1 {
                            selectedCards.append(thisCard)
                            
                            if thisCard == touchedCard { break }
                        } else {
                            break
                        }
                    }
                }
                

                for card in selectedCards.sorted(by: { $0.zPosition < $1.zPosition }) {
                    card.moveToFront()
                }
                return selectedCards
            }
            
            // each card moved off the tableau should be moved on top of other cards
            tableau.unsnapAction = { (_ unsnappedCards) in
                for card in unsnappedCards.sorted(by: { $0.zPosition < $1.zPosition }) {
                    card.moveToFront()
                }
            }
            
            self.snapLocations.append(tableau)
            self.tableauLocations.append(tableau)
        }
        
        for snapLocation in self.snapLocations {
            self.drawNode(rectangle: snapLocation.snapRect)
        }
        
        self.initDividerLine(hidden: true)
        self.loadCards(fromSaved: loadSaved)
        
    }
    
    /**
     Shuffles cards and deals a new game
     */
    override func shuffleAndStackAllCards(sync: Bool) {
        
        DispatchQueue.global(qos: .default).async {
            self.scores[0].score -= 52
            
            for foundation in self.foundations {
                self.scores[0].score += Double(foundation.snappedCards.count) * 3
            }
            
            self.updateScoreLabel()
            
            for snapLocation in self.snapLocations {
                snapLocation.unSnapAll()
            }
            
            for card in self.allCards {
                card.isHidden = true
            }
            
            Global.shuffle(&self.allCards)
            
            for card in self.allCards {
                card.moveToFront()
                card.flip(faceUp: false, sendPosition: false)
            }
            
            usleep(useconds_t(CardSpriteNode.flipDuration * 1000000))
            
            for tableauLocation in self.tableauLocations {
                tableauLocation.yOffset = self.initialTableauOffset
            }
            
            var sortedCards = self.allCards.sorted { $0.zPosition < $1.zPosition }
            for _ in 0...7 {
                for tableauLocation in self.tableauLocations {

                    if let topCard = sortedCards.popLast() {
                        topCard.isHidden = false
                        tableauLocation.snap(topCard)
                        usleep(useconds_t(self.dealDuration * 1000000))
                    }

                }
            }
            
            self.saveGame()
        }
        
    }
    
    override func popUpMenuItems(at touchLocation: CGPoint) -> [PopUpMenuItem]? {
        return [PopUpMenuItem(title: "autocomplete".localized, action: {(_: Any?) in
            self.autoComplete()
        }, parameter: nil)]
    }
    
    override func selectMultipleNodesForTouch(touchLocation: CGPoint) {
        for card in self.selectedNodes {
            DispatchQueue.global(qos: .default).async {
                card.pop()
            }
        }
    }
    
    // MARK: - Private methods

    private func autoComplete() {
        DispatchQueue.global(qos: .default).async {
            var done = false
            
            while !done {
                done = true
                
                for cell in self.cells {
                    if let topCard = cell.topCard {
                        for foundation in self.foundations {
                            if foundation.isSnappable(topCard) {
                                cell.unSnap(cards: [topCard])
                                foundation.snap(topCard)
                                usleep(useconds_t(self.dealDuration * 1000000))
                                done = false
                                break
                            }
                        }
                    }
                }
                
                for tableau in self.tableauLocations {
                    if let topCard = tableau.topCard {
                        for foundation in self.foundations {
                            if foundation.isSnappable(topCard) {
                                tableau.unSnap(cards: [topCard])
                                foundation.snap(topCard)
                                usleep(useconds_t(self.dealDuration * 1000000))
                                done = false
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}
