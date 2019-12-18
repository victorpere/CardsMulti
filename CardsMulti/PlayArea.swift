//
//  PlayArea.swift
//  CardsMulti
//
//  Created by Victor on 2019-12-09.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import CoreGraphics

class PlayArea {
    // MARK: - Properties
    
    /// The rectangle defining the play area
    var areaRect: CGRect
    
    /// Action to perform on a card when double tapped. Default is flip
    var doubleTapAction: (CardSpriteNode) -> Void = {(_ card) in card.flip(sendPosition: true)}
    
    // MARK: - Initializers
    
    /**
     Initializes play area with a rectangle
     
     - parameter area: play area rectangle
     */
    init(area: CGRect) {
        self.areaRect = area
    }
    
    // MARK: - Public methods
    
    /**
     Determines whether the specified card is within this area
     
     - parameter card: card to examine
     */
    func contains(card: CardSpriteNode) -> Bool {
        return self.areaRect.contains(card.position)
    }
}
