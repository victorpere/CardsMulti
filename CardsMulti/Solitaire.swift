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
    
    /// Vertical offset of cards in the tableau
    let tableauOffset: CGFloat = -20
    
    /// Duration to move a card to its starting postion in seconds
    let dealDuration = 0.1
    
    // MARK: - Properties
    
    var tableauLocations = [SnapLocation]()
    var foundations = [SnapLocation]()
    var stockPile: SnapLocation!
    
    // MARK: - Computed properties

    
    // MARK: - Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        Settings.instance.cardWidthsPerScreen = self.cardWidthsPerScreen
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
        
        self.snapLocations.removeAll()
        
        let snapLocationSize = CGSize(width: self.cardWidthPixels, height: self.cardHeightPixels)
        
        // Stock pile
        self.stockPile = SnapLocation(location: CGPoint(x: self.cardWidthPixels / 2 + self.margin, y: self.frame.height - self.cardWidthPixels - self.margin - self.topMargin), snapSize: snapLocationSize)
        self.stockPile.name = "Stock Pile"
        self.stockPile.xOffset = CGFloat(self.verticalHeight)
        self.stockPile.yOffset = CGFloat(self.verticalHeight)
        self.stockPile.shouldFlip = true
        self.stockPile.faceUp = false
        //self.stockPile.putOnTop = false
        self.snapLocations.append(self.stockPile)
        
        // Waste pile
        
        
        // Foundations
        for col in 1...4 {
            let location = CGPoint(x: self.frame.width - self.margin * CGFloat(col) - self.cardWidthPixels * CGFloat(col) + self.cardWidthPixels / 2, y: self.frame.height - self.cardWidthPixels - self.margin - self.topMargin)
            let foundation = SnapLocation(location: location, snapSize: snapLocationSize)
            foundation.name = "Foundation \(col)"
            foundation.xOffset = CGFloat(self.verticalHeight)
            foundation.yOffset = CGFloat(self.verticalHeight)
            
            // conditions for adding cards to the foundations
            foundation.snappableConditionMet = { (_ foundation, _ card) in
                if foundation.topCard == nil {
                    return card.card?.rank == Rank.ace
                }
                
                return foundation.topCard!.card?.suit == card.card?.suit && ((foundation.topCard!.card?.rank.rawValue)! + 1 == card.card?.rank.rawValue || (foundation.topCard!.card?.rank == Rank.ace && card.card?.rank == Rank.two))
            }
            
            // cards snapped to foundations are not movable
            foundation.movableConditionMet = { (_, _) in return false}
            
            self.snapLocations.append(foundation)
            self.foundations.append(foundation)
        }
        
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
            tableau.movableConditionMet = { (_, _ card) in
                return card.faceUp
            }
            
            // double tap moves the car to a foundation if possible
            tableau.doubleTapAction = { (_ tableau) in
                if let topCard = tableau.topCard {
                    for foundation in self.foundations {
                        if foundation.snappableConditionMet(foundation, topCard) {
                            tableau.unSnap([topCard])
                            foundation.snap(topCard)
                            return
                        }
                    }
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
    override func resetCards(sync: Bool) {
        
        DispatchQueue.global(qos: .default).async {
            for snapLocation in self.snapLocations {
                snapLocation.unSnapAll()
            }
            
            for card in self.allCards {
                card.isHidden = true
            }
            
            Global.shuffle(&self.allCards)
            var sortedCards = self.allCards.sorted { $0.zPosition < $1.zPosition }
            
            for card in self.allCards {
                card.flip(faceUp: false, sendPosition: false)
            }
            
            usleep(useconds_t(CardSpriteNode.flipDuration * 1000000))
            
            for tableauLocation in self.tableauLocations {
                tableauLocation.faceUp = false
            }
            
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