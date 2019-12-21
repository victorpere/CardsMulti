//
//  SnapLocation.swift
//  CardsMulti
//
//  Created by Victor on 2019-11-09.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import CoreGraphics

/// An object describing a location and rules that cards should snap to when moved within a close distance
class SnapLocation {
    
    // MARK: - Properties
    
    /// Name of the snap location
    var name: String = "Default"
    
    /// Co-oridnates of the snap location in the scene
    var location: CGPoint
    
    /// Rectangle within which cards should snap to this location
    var snapRect: CGRect
    
    /// Whether the card should rotate to the rotation property when snapping to this location. Default is true
    var shouldRotate = true
    
    /// The rotation of the snapped card if shouldRotate is set to true. Default is 0
    var rotation: CGFloat = 0
    
    /// Whether multiple cards can be snapped at once. Default is false
    var canSnapMultiple = false
    
    /// Whether cards should be stacked when snapping multiple cards if canSnapMultiple is true. Default is false
    var stackAll = false
    
    /// Offset along x-axis when the card snaps on top of other cards. Default is 0
    var xOffset: CGFloat = 0
    
    /// Offset along y-axis when the card snaps on top of other cards. Default is 0
    var yOffset: CGFloat = 0
    
    /// Rotation offset when the card snaps on top of other cards. Default is 0
    var rotationOffset: CGFloat = 0
    
    /// Whether the card should flip when snapping. Default is false
    var shouldFlip = false
    
    /// Whether the card should turn face up or face down if shouldFlip is true. Default is true
    var faceUp = true
    
    /// Whether new cards should go on top or bottom of the set of snapped cards. Default is true
    var putOnTop = true
    
    /// Whether snap area should expand to include the area of cards that are snapped to this location. Default is false
    var snapAreaIncludesCards = false
    
    /// Whether more cards can be snapped to this location. Default is true
    var canAddCards = true
    
    /// maximum number of cards allowed to snap to this location
    var maxCards = Int.max
    
    /// Set of cards snapped to this location
    var snappedCards: [CardSpriteNode]
    
    /// Designated location where cards from this location can be moved
    var destinationSnapLocation: SnapLocation?
    
    /// Duration of snapping animation
    var duration: Double = 0.2
    
    /// Closure defining the rule for snapping a new card to this location. Default returns true for all
    var snappableConditionMet: (SnapLocation, CardSpriteNode) -> Bool = { (_, _) in return true }
    
    /// Closure defining the rule for whether a card can be selected to be moved. Default returns true for all
    var movableConditionMet: (SnapLocation, CardSpriteNode) -> Bool = { (_, _) in return true }
    
    /// Action to perform when the snap location is doulbe-tapped. Default is flip top card
    var doubleTapAction: (SnapLocation) -> Void = { (_ snapLocation) in
        if let topCard = snapLocation.topCard {
            topCard.flip(faceUp: !topCard.faceUp, sendPosition: true)
        }
    }
    
    /// Optional action to performed when a card in the snap location is tapped
    var tapAction: ((SnapLocation, CardSpriteNode) -> Void)?
    
    /// Action to perform on cards when they are unsnapped. Default is nothing
    var unsnapAction: ([CardSpriteNode]) -> Void = { (_) in }
    
    /// Cards to be selected when a card in the location is touched. Default is the card itself
    var selectedCardsWhenTouched: (SnapLocation, CardSpriteNode) -> [CardSpriteNode] = { (_, card)  in return [card] }
    
    // MARK: - Computed properties
    
    /// The topmost card of the snapped cards
    var topCard: CardSpriteNode? {
        let sortedCards = self.snappedCards.sorted { $0.zPosition > $1.zPosition }
        return sortedCards.first
    }
    
    // MARK: - Initializers
    
    /**
     Initializes location and default snap distance
     
     - parameter location: co-ordinates of the snap location
     */
    init(location: CGPoint) {
        self.location = location
        self.snapRect = CGRect(center: location, size: CGSize(width: Config.snapDistance * 2, height: Config.snapDistance * 2))
        self.snappedCards = []
    }
    
    /**
     Initializes location and snap distance
     
     - parameters:
        - location: co-ordinates of the snap location
        - snapDistance: distance at which cards should snap
     */
    init(location: CGPoint, snapDistance: CGFloat) {
        self.location = location
        self.snapRect = CGRect(center: location, size: CGSize(width: snapDistance * 2, height: snapDistance * 2))
        self.snappedCards = []
    }
    
    /**
     Initializes location given the size
     
     - parameters:
        - location: co-ordinates of the snap location
        - snapSize: size of the area to which cards should snap
     */
    init(location: CGPoint, snapSize: CGSize) {
        self.location = location
        self.snapRect = CGRect(center: location, size: snapSize)
        self.snappedCards = []
    }
    
    // MARK: - Public methods
    
    /**
    Determines whether a card at the specified location should snap to this location
    
    - parameters:
       - location: the location to examine
    
    - returns: True if a card should snap
    */
    func shouldSnap(atLocation location: CGPoint) -> Bool {
        if !self.canAddCards && self.snappedCards.count < self.maxCards {
            return false
        }
        
        if self.snapRect.contains(location) {
            return true
        }
        
        if self.snapAreaIncludesCards {
            for card in self.snappedCards {
                if card.pointInCard(location) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /**
     Determines whether the specified card should snap to this location
     
     - parameters:
        - cardNode: the card node to examine
     
     - returns: True if the card should snap
     */
    func shouldSnap(cardNode: CardSpriteNode) -> Bool {
        return self.snappableConditionMet(self, cardNode) && self.shouldSnap(atLocation: cardNode.position)
    }
    
    /**
    Determines whether the set of cards should snap to this location
    
    - parameters:
       - cardNode: the set of cards to examine
    
    - returns: True if the set of cards should snap
    */
    func shouldSnap(cardNodes: [CardSpriteNode]) -> Bool {
        if self.canAddCards && self.canSnapMultiple && self.snappedCards.count + cardNodes.count <= self.maxCards {
            let sortedCards = cardNodes.sorted { $0.zPosition < $1.zPosition }
            if let bottomCard = sortedCards.first {
                return self.shouldSnap(cardNode: bottomCard)
            }
        }
        return false
    }
    
    /**
     Snaps the specified card to this location
     
     - parameter cardNode: the card node to snap
     */
    func snap(_ cardNode: CardSpriteNode) {
        // remove this card if it is already snapped
        if let cardNodeIndex = self.snappedCards.lastIndex(of: cardNode) {
            self.snappedCards.remove(at: cardNodeIndex)
        }
        
        // determine location for the new card
        let xOffset = self.xOffset * CGFloat(self.snappedCards.count)
        let yOffset = self.yOffset * CGFloat(self.snappedCards.count)
        let newLocation = CGPoint(x: self.location.x + xOffset, y: self.location.y + yOffset)
        
        // determine rotation if it needs to be changed
        let rotationOffset = self.shouldRotate ? self.rotationOffset * CGFloat(self.snappedCards.count) : 0
        let newRotation = self.shouldRotate ? self.rotation + rotationOffset : cardNode.zRotation
        
        // determine if the card needs to be flipped
        let newFaceUp = self.shouldFlip ? self.faceUp : cardNode.faceUp
        
        // determine whether the card needs to go on the top or bottom of the pile
        if self.putOnTop {
            cardNode.moveToFront()
        } else {
            cardNode.moveToBack()
        }
        
        // perform the movement
        cardNode.moveAndFlip(to: newLocation, rotateToAngle: newRotation, faceUp: newFaceUp, duration: self.duration, sendPosition: true, animateReceiver: false)
        
        self.snappedCards.append(cardNode)
        cardNode.snapLocation = self
        
        print("added to snapped \(self.name)")
        Global.displayCards(self.snappedCards)
    }
    
    /**
     Snaps multiple cards to this location
     
     - parameter cardNodes: array of cards to snap
     */
    func snap(_ cardNodes: [CardSpriteNode]) {
        let sortedCards = cardNodes.sorted { $0.zPosition < $1.zPosition }
        for card in sortedCards {
            self.snap(card)
        }
    }
    
    /**
     Removes the specified set of cards from the set of cards snapped to this location
     
     - parameter cardNodes: set of cards to unsnap
     */
    func unSnap(cards cardsToUnsnap: [CardSpriteNode]) {
        for cardNode in cardsToUnsnap {
            cardNode.snapLocation = nil
        }

        let unsnappedCards = Array(Set(self.snappedCards).intersection(cardsToUnsnap))
        self.snappedCards = Array(Set(self.snappedCards).subtracting(cardsToUnsnap))
        
        // flip the top card if needed
        if self.topCard != nil && self.shouldFlip {
            self.topCard!.flip(faceUp: self.faceUp, sendPosition: true)
        }
        
        self.unsnapAction(unsnappedCards)
        
        if unsnappedCards.count > 0 {
            print("removed from snapped \(self.name)")
            Global.displayCards(self.snappedCards)
        }
    }
    
    /**
     Removes all cards from this location
     */
    func unSnapAll() {
        for cardNode in self.snappedCards {
            cardNode.snapLocation = nil
        }
        self.unsnapAction(self.snappedCards)
        self.snappedCards.removeAll()
        
        print("removed all from snapped \(self.name)")
    }
    
    /**
     Selects all selectable cards
     
     - returns: All snapped cards that are selectable
     */
    func movableCardNodes() -> [CardSpriteNode] {
        return self.snappedCards.filter { self.movableConditionMet(self, $0) }
    }
}


