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
    
    /// Sets the size of the cards
    let cardWidthsPerScreen: Float = 8
    
    /// Width of a card in pixels
    let cardWidthPixels = CardSpriteNode.cardWidthPixels(forCardWidthsPerScreen: 8)
    let cardHeightPixels = CardSpriteNode.cardHeightPixels(forCardWidthsPerScreen: 8)
    
    /// The margin between piles or piles and screen edge
    let margin: CGFloat = 5
    
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
    
    override init(size: CGSize) {
        super.init(size: size)
        self.doubleTapAction = { (_ card) in
            for foundation in self.foundations {
                if foundation.snappableConditionMet(card) {
                    if let snapLocation = card.snapLocation {
                        snapLocation.unSnap(cards: [card])
                    }
                    foundation.snap(card)
                    return
                }
            }
        }
        
        Settings.instance.cardWidthsPerScreen = self.cardWidthsPerScreen
        
        let player = Player(peerId: self.myPeerId, position: Position.bottom)
        self.players?.append(player)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - GameScene override methods
    
    /**
     Resets the game
     
     */
    override func resetGame(sync: Bool, loadSaved: Bool = false) {
        self.removeAllChildren()
        //self.players![0].score = -52
        
        self.snapLocations.removeAll()
        
        let snapLocationSize = CGSize(width: self.cardWidthPixels, height: self.cardHeightPixels)
        
        // Foundations
        for col in 1...4 {
            let location = CGPoint(x: self.margin * CGFloat(col) + self.cardWidthPixels * CGFloat(col) - self.cardWidthPixels / 2, y: self.frame.height - self.cardWidthPixels - self.margin - self.topMargin)
            let foundation = SnapLocation(location: location, snapSize: snapLocationSize)
            foundation.name = "Foundation \(col)"
            foundation.xOffset = CGFloat(self.verticalHeight)
            foundation.yOffset = CGFloat(self.verticalHeight)
            
            // conditions for adding cards to the foundations
            foundation.snappableConditionMet = { (_ card) in
                if foundation.topCard == nil {
                    return card.card?.rank == Rank.ace
                }
                
                return foundation.topCard!.card?.suit == card.card?.suit && ((foundation.topCard!.card?.rank.rawValue)! + 1 == card.card?.rank.rawValue || (foundation.topCard!.card?.rank == Rank.ace && card.card?.rank == Rank.two))
            }
            
            // top car in the foudation is movable
            foundation.movableConditionMet = { (_ card) in
                return card == foundation.topCard
            }
            
            self.snapLocations.append(foundation)
            self.foundations.append(foundation)
        }
        
        // Stock pile
        self.stockPile = SnapLocation(location: CGPoint(x: self.frame.width - self.cardWidthPixels / 2 - self.margin, y: self.frame.height - self.cardWidthPixels - self.margin - self.topMargin), snapSize: snapLocationSize)
        self.stockPile.name = "Stock Pile"
        self.stockPile.xOffset = CGFloat(self.verticalHeight)
        self.stockPile.yOffset = CGFloat(self.verticalHeight)
        self.stockPile.shouldFlip = true
        self.stockPile.faceUp = false
        
        self.stockPile.tapAction = { (_) in
            if let topCard = self.stockPile.topCard {
                self.stockPile.unSnap(cards: [topCard])
                self.wastePile.snap(topCard)
            } else {
                let cards = self.wastePile.snappedCards
                self.wastePile.unSnapAll()
                cards.reverseOrder()
                self.stockPile.snap(cards)
            }
        }
        
        self.stockPile.movableConditionMet = { (_ card) in
            return card == self.stockPile.topCard
        }
        
        // select top 3 cards from the stock pile when touched
        self.stockPile.selectedCardsWhenTouched = { (_ touchedCard) in
            /*
            let selectedCards = Array(self.stockPile.snappedCards.sorted { $0.zPosition > $1.zPosition }.prefix(upTo: 3))
            for card in selectedCards {
                card.moveToFront()
            }
            return selectedCards
            */
            //if let topCard = self.stockPile.topCard {
            //    return [topCard]
            //}
            return []
        }
        
        self.snapLocations.append(self.stockPile)
        
        // Waste pile
        self.wastePile = SnapLocation(location: CGPoint(x: self.stockPile.location.x - self.cardWidthPixels - 3 * self.margin, y: self.stockPile.location.y), snapSize: snapLocationSize)
        self.wastePile.name = "Waste Pile"
        self.wastePile.shouldFlip = true
        self.wastePile.faceUp = true
        self.wastePile.xOffset = CardSpriteNode.stackOffset
        self.wastePile.yOffset = CardSpriteNode.stackOffset

        self.wastePile.doubleTapAction = { (wastePile) in
            if let topCard = wastePile.topCard {
                for foundation in self.foundations {
                    if foundation.snappableConditionMet(topCard) {
                        wastePile.unSnap(cards: [topCard])
                        foundation.snap(topCard)
                        return
                    }
                }
            }
        }
        
        self.snapLocations.append(self.wastePile)
        
        // Tableau
        for col in 0...6 {
            let location = CGPoint(x: self.cardWidthPixels / 2 + self.margin * CGFloat(col + 1) + self.cardWidthPixels * CGFloat(col), y: self.frame.height - self.cardWidthPixels * 3 - self.margin - self.topMargin)
            let tableau = SnapLocation(location: location, snapSize: snapLocationSize)
            tableau.name = "Tableau \(col + 1)"
            tableau.yOffset = self.tableauOffset
            tableau.snapAreaIncludesCards = true
            tableau.shouldFlip = true
            tableau.faceUp = false
            
            // only face up cards are movable
            tableau.movableConditionMet = { (card) in
                return card.faceUp
            }
            
            // conditions for adding cards to a tableau
            tableau.snappableConditionMet = { (_ card) in
                if let topCard = tableau.topCard {
                    return topCard.card?.suit.color != card.card?.suit.color && topCard.card?.rank.rawValue == (card.card?.rank.rawValue)! + 1
                }
                return card.card?.rank == Rank.king
            }
            
            // double tap moves the car to a foundation if possible
            tableau.doubleTapAction = { (_ tableau) in
                if let topCard = tableau.topCard {
                    for foundation in self.foundations {
                        if foundation.snappableConditionMet(topCard) {
                            tableau.unSnap(cards: [topCard])
                            foundation.snap(topCard)
                            return
                        }
                    }
                }
            }
            
            // when a card in the tableau is touched, select the card and all cards on top of it
            tableau.selectedCardsWhenTouched = { (_ touchedCard) in
                return tableau.snappedCards.filter { $0.faceUp && $0.zPosition >= touchedCard.zPosition }
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
    override func resetCards(sync: Bool) {
        
        DispatchQueue.global(qos: .default).async {
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
}
