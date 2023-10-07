//
//  GameGoFish.swift
//  CardsMulti
//
//  Created by Victor on 2019-09-21.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation
import CoreGraphics

class GameGoFish : GameScene {
    
    var stockPile: [CardSpriteNode]?
    
    // MARK: - Initializers
    
    init(size: CGSize, loadFromSave: Bool) {
        super.init(size: size, gameType: .goFish, loadFromSave: loadFromSave)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - GameScene override methods
    
    
    override func restartGame(sync: Bool) {
        super.restartGame(sync: sync)
        
        self.deal()
    }
    
    override func popUpMenuItems(at touchLocation: CGPoint) -> [PopUpMenuItem]? {
        return nil
    }
    
    override func deal() {
        
//        for peerId in self.peers {
//            if peerId != nil {
//                let score = Score(peerId: peerId!, name: "Books", gameType: .goFish)
//                self.scores.append(score)
//            }
//        }
        
        
        var numberOfCardsToDeal: Int
        switch self.numberOfPlayers {
            case 1,2:
                numberOfCardsToDeal = 7
            case 3,4:
                numberOfCardsToDeal = 5
            default:
                return
        }
            
        let _ = self.deal(fromCards: self.allCards, numberOfCards: numberOfCardsToDeal) { remainingCards in
            self.stockPile = remainingCards
            
            self.pool(cardNodes: remainingCards, centeredIn: self.playArea.center, withRadius: self.playArea.height / 3, flipFaceUp: false)
        }
        
    }
}
