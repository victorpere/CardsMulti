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
    
    override init(size: CGSize, loadFromSave: Bool) {
        super.init(size: size, gameType: .GoFish, loadFromSave: loadFromSave)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - GameScene override methods
    
    override func resetGame(sync: Bool, loadSaved: Bool = false) {
        super.resetGame(sync: sync, loadSaved: loadSaved)
        
        self.deal()
    }
    
    override func deal() {
        
        for peerId in self.peers {
            if peerId != nil {
                let score = Score(peerId: peerId!, name: "Books", gameType: .GoFish)
                self.scores.append(score)
            }
        }
        
        
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
        
        self.stockPile = dealResult.remainingCards
        
        /*
        DispatchQueue.global(qos: .default).async {
            usleep(useconds_t(dealResult.duration * 1000000))
            
            self.pool(cardNodes: dealResult.remainingCards, centeredIn: self.playArea.center, withRadius: self.playArea.height / 3, flipFaceUp: false)
        }
         */
    }
}
