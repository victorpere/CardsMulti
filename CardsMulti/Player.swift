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
    var peerId: MCPeerID
    var position: Position
    var hand = [CardSpriteNode]()
    
    init(peerId: MCPeerID, position: Position) {
        self.peerId = peerId
        self.position = position
    }
}
