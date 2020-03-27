//
//  Player.swift
//  CardsMulti
//
//  Created by Victor on 2019-09-21.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Player {
    // MARK: - Properties
    
    var peerId: MCPeerID
    
    /// The player's position in relation to the table
    var position: Position
    
    var scores: [Score]!
    var score: Float = 0
    
    var hand = [CardSpriteNode]()
    
    // MARK: - Initializers
    
    init(peerId: MCPeerID, position: Position) {
        self.peerId = peerId
        self.position = position
    }
}
