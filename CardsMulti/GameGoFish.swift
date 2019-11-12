//
//  GameGoFish.swift
//  CardsMulti
//
//  Created by Victor on 2019-09-21.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

class GameGoFish : GameScene {
    
    
    func deal() {
        precondition(self.numberOfPlayers() > 1)
        
        switch self.numberOfPlayers() {
        case 2,3:
            self.deal(numberOfCards: 7)
        case 4:
            self.deal(numberOfCards: 5)
        default:
            break
        }
    }
}
