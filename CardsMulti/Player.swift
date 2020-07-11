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
    
    /// MultipeerConnectivity ID
    var peerId: MCPeerID?
    
    /// Websockets connection ID
    var connectionId: String?
    
    /// Websockets game ID
    var gameId: String?
    
    /// The player's position in relation to the table
    var position: Position?
    
    /// The player's display name
    var displayName: String
    
    // MARK: - Initializers
    
    init(peerId: MCPeerID) {
        self.peerId = peerId
        self.displayName = peerId.displayName
    }
    
    init(connectionId: String, displayName: String) {
        self.connectionId = connectionId
        self.displayName = displayName
    }
}
