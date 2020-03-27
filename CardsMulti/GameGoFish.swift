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
    
    
    
    // MARK: - GameScene override methods
    
    override func resetGame(sync: Bool, loadSaved: Bool = false) {
        super.resetGame(sync: sync, loadSaved: loadSaved)
        
        self.deal()
    }
    
    override func deal() {
        var numberOfCardsToDeal: Int
        switch self.numberOfPlayers {
            case 2,3:
                numberOfCardsToDeal = 7
            case 4:
                numberOfCardsToDeal = 8
            default:
                return
        }
            
        let dealResult = self.deal(fromCards: self.allCards, numberOfCards: numberOfCardsToDeal)
        
        /*
        DispatchQueue.global(qos: .default).async {
            usleep(useconds_t(dealResult.duration * 1000000))
            
            self.pool(cardNodes: dealResult.remainingCards, centeredIn: self.playArea.center, withRadius: self.playArea.height / 3, flipFaceUp: false)
        }
         */
    }
}
