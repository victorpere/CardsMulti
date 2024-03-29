//
//  Solitaire.swift
//  CardsMulti
//
//  Created by Victor on 2019-11-09.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import GameKit

/// Subclass of GameScene for playing single player basic solitaire
class Solitaire : GameScene {
    
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
    var stockPile: SnapLocation!
    var wastePile: SnapLocation!
    var playPile: SnapLocation!
    
    // MARK: - Computed properties

    /// Current game score
    var score: Int {
        var score = -52
        for foundation in self.foundations {
            score += 3 * foundation.snappedCards.count
        }
        return score
    }
    
    // MARK: - Initializers
    
    init(size: CGSize, loadFromSave: Bool) {
        super.init(size: size, gameType: .solitare, loadFromSave: loadFromSave)
        
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
        
        self.buttonActions["autocomplete"] = self.autoComplete
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - GameScene override methods
    
    /**
     Resets the game
     
     */
    override func loadCards(fromSaved loadSaved: Bool, sync: Bool = false) {
        super.loadCards(fromSaved: loadSaved, sync: sync)
        
        if loadSaved {
            for tableauLocation in self.tableauLocations {
                tableauLocation.faceUp = true
            }
        }
    }
    
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
        
        // Foundations
        for col in 1...4 {
            let location = CGPoint(x: self.margin * CGFloat(col) + self.cardWidth * CGFloat(col) - self.cardWidth / 2, y: self.frame.height - self.cardWidth - self.margin - self.topMargin)
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
        
        // Stock pile
        self.stockPile = SnapLocation(location: CGPoint(x: self.frame.width - self.cardWidth / 2 - self.margin, y: self.frame.height - self.cardWidth - self.margin - self.topMargin), snapSize: snapLocationSize)
        self.stockPile.name = "Stock Pile"
        self.stockPile.xOffset = CGFloat(self.verticalHeight)
        self.stockPile.yOffset = CGFloat(self.verticalHeight)
        self.stockPile.shouldFlip = true
        self.stockPile.faceUp = false
        
        self.stockPile.tapAction = { (_) in
            let playPileCards = self.playPile.snappedCards
            self.playPile.unSnapAll()
            self.wastePile.snap(playPileCards)
                        
            if self.stockPile.snappedCards.count > 0 {
                let numberToSelect = self.stockPile.snappedCards.count > 3 ? 3 : self.stockPile.snappedCards.count
                let selectedCards = Array(self.stockPile.snappedCards.sorted { $0.zPosition > $1.zPosition }.prefix(upTo: numberToSelect))
                for card in selectedCards {
                    card.moveToFront()
                }
                self.stockPile.unSnap(cards: selectedCards)
                self.playPile.snap(selectedCards, withDelay: 0.05)
            } else {
                let cards = self.wastePile.snappedCards
                self.wastePile.unSnapAll()
                cards.reverseOrder()
                self.stockPile.snap(cards)
            }
        }
        
        self.stockPile.isMovable = { (_ card) in
            return false
        }
        
        self.stockPile.isSnappable = { (_) in
            return false
        }
        
        // select up to 3 top cards from the stock pile when touched
        self.stockPile.selectedCardsWhenTouched = { (_ touchedCard) in
            return []
        }
        
        self.snapLocations.append(self.stockPile)
        
        // Waste pile
        self.wastePile = SnapLocation(location: CGPoint(x: self.stockPile.location.x - self.cardWidth - 10 * self.margin, y: self.stockPile.location.y), snapSize: snapLocationSize)
        self.wastePile.name = "Waste Pile"
        self.wastePile.shouldFlip = true
        self.wastePile.faceUp = true
        self.wastePile.unsnapWhenMoved = false
        self.wastePile.snapBack = true
        
        self.wastePile.isMovable = { (_ card) in
            return card == self.wastePile.topCard
        }
        
        self.wastePile.isSnappable = { (_) in
            return false
        }

        self.wastePile.doubleTapAction = { (wastePile) in
            if let topCard = wastePile.topCard {
                for foundation in self.foundations {
                    if foundation.isSnappable(topCard) {
                        wastePile.unSnap(cards: [topCard])
                        foundation.snap(topCard)
                        return
                    }
                }
            }
        }
        
        self.wastePile.selectedCardsWhenTouched = { (_ touchedCard) in
            if self.playPile.snappedCards.count == 0 && touchedCard == self.wastePile.topCard {
                return [touchedCard]
            }
            return []
        }
        
        self.snapLocations.append(self.wastePile)
        
        // Play pile
        self.playPile = SnapLocation(location: self.wastePile.location, snapSize: snapLocationSize)
        self.playPile.name = "Play Pile"
        self.playPile.shouldFlip = true
        self.playPile.faceUp = true
        self.playPile.xOffset = 20
        self.playPile.snapAreaIncludesCards = true
        self.playPile.unsnapWhenMoved = false
        self.playPile.snapBack = true
        
        self.playPile.isMovable = { (_ card) in
            return card == self.playPile.topCard
        }
        
        self.playPile.isSnappable = { (_) in
            return false
        }
        
        self.playPile.doubleTapAction = { (pile) in
            if let topCard = pile.topCard {
                for foundation in self.foundations {
                    if foundation.isSnappable(topCard) {
                        pile.unSnap(cards: [topCard])
                        foundation.snap(topCard)
                        return
                    }
                }
            }
        }
        
        self.playPile.selectedCardsWhenTouched = { (_ touchedCard) in
            if touchedCard == self.playPile.topCard {
                return [touchedCard]
            }
            return []
        }
        
        self.snapLocations.append(self.playPile)
        
        // Tableau
        for col in 0...6 {
            let location = CGPoint(x: self.cardWidth / 2 + self.margin * CGFloat(col + 1) + self.cardWidth * CGFloat(col), y: self.frame.height - self.cardWidth * 3 - self.margin - self.topMargin)
            let tableau = SnapLocation(location: location, snapSize: snapLocationSize)
            tableau.name = "Tableau \(col + 1)"
            tableau.yOffset = self.initialTableauOffset
            tableau.snapAreaIncludesCards = true
            tableau.shouldFlip = true
            tableau.faceUp = false
            tableau.unsnapWhenMoved = false
            tableau.snapBack = true
            
            // only face up cards are movable
            tableau.isMovable = { (card) in
                return card.faceUp
            }
            
            // conditions for adding cards to a tableau
            tableau.isSnappable = { (_ card) in
                if let topCard = tableau.topCard {
                    return topCard.card.suit.color != card.card.suit.color && topCard.card.rank.rawValue == card.card.rank.rawValue + 1
                }
                return card.card.rank == Rank.king
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
                let selectedCards = tableau.snappedCards.filter { $0.faceUp && $0.zPosition >= touchedCard.zPosition }
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
                tableauLocation.faceUp = false
                tableauLocation.yOffset = self.initialTableauOffset
            }
            
            var sortedCards = self.allCards.sorted { $0.zPosition < $1.zPosition }
            for row in 0...6 {
                for (tableauNumber, tableauLocation) in self.tableauLocations.enumerated() {
                    if row <= tableauNumber {
                        if let topCard = sortedCards.popLast() {
                            if row == tableauNumber {
                                tableauLocation.faceUp = true
                            }
                            topCard.isHidden = false
                            tableauLocation.snap(topCard)
                            usleep(useconds_t(self.dealDuration * 1000000))
                        }
                    }
                }
            }
            
            for card in sortedCards {
                card.isHidden = false
                self.stockPile.snap(card)
            }
        }
        
    }
    
    override func popUpMenuItems(at touchLocation: CGPoint) -> [PopUpMenuItem]? {
        let autocompleteItem = PopUpMenuItem(title: "autocomplete".localized, action: {(_: Any?) in
            self.autoComplete()
        }, parameter: nil)
        
        let resetScoresItem = PopUpMenuItem(title: UIStrings.resetScore, action: {(_: Any?) in
            self.resetScores()
        }, parameter: nil)
        
        return [autocompleteItem, resetScoresItem]
    }
    
    override func resetScores() {
        if let score = self.scores.first(where: { $0.name == "RunningScore" }) {
            score.score = 0
        } else {
            if !self.scores.contains(where: { $0.name == "RunningScore" }) {
                self.scores.append(Score(peerId: self.myPeerId, name: "RunningScore", gameType: self.gameType))
            }
        }
        
        self.updateScoreLabel()
    }
    
    // MARK: - Private methods

    private func autoComplete() {
        DispatchQueue.global(qos: .default).async {
            var done = false
            
            while !done {
                done = true
                
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
                
                if let topCard = self.playPile.topCard {
                    for foundation in self.foundations {
                        if foundation.isSnappable(topCard) {
                            self.playPile.unSnap(cards: [topCard])
                            foundation.snap(topCard)
                            usleep(useconds_t(self.dealDuration * 1000000))
                            done = false
                            break
                        }
                    }
                }
                
                if self.playPile.snappedCards.count == 0, let topCard = self.wastePile.topCard {
                    for foundation in self.foundations {
                        if foundation.isSnappable(topCard) {
                            self.wastePile.unSnap(cards: [topCard])
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
