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
    var position: Position = .bottom
    
    /// The player's display name
    var displayName: String = "unknown player"
    
    /// Dictionary representing AWS player properties
    var playerDictionary: NSDictionary {
        return NSDictionary(dictionary: [
            Key.connectionId.rawValue: self.connectionId ?? "",
            Key.displayName.rawValue: self.displayName,
            Key.position.rawValue: self.position.rawValue 
        ])
    }
    
    enum Key : String {
        case connectionId = "connectionId"
        case displayName = "displayName"
        case position = "position"
    }
    
    // MARK: - Initializers
    
    /**
     Initializer for local player
     */
    init(peerId: MCPeerID) {
        self.peerId = peerId
        self.displayName = peerId.displayName
    }
    
    /**
     Initializer for AWS player
     */
    init(connectionId: String, displayName: String) {
        self.connectionId = connectionId
        self.displayName = displayName
    }
    
    /**
     Initializes player from a dictionary
     */
    init(with dictionary: NSDictionary) throws {
        if let value = dictionary[Key.connectionId.rawValue] as? String {
            self.connectionId = value
        } else {
            throw PlayerError.FailToDecodePlayerError
        }
        if let value = dictionary[Key.displayName.rawValue] as? String {
            self.displayName = value
        } else {
            throw PlayerError.FailToDecodePlayerError
        }
        if let value = dictionary[Key.position.rawValue] as? Int {
            self.position = Position(rawValue: value) ?? .bottom
        }
    }
    
}

// MARK: - Player array extension

extension Array where Element == Player? {
    
    /// An array of player dictionary properties
    var dictionaries: [NSDictionary?] {
        return self.map({ $0?.playerDictionary })
    }
    
    /// Acomma-separated string of all players' connection IDs
    var connectionIds: String {
        let filtered = self.filter { $0 != nil && $0?.connectionId != nil}
        let connectionIds = filtered.map({ $0!.connectionId }) as! [String]
        return connectionIds.joined(separator: ",")
    }
    
    /// Checks if the player array is correct
    var valid: Bool {
        if self.count > Config.maxPlayers { return false }
        return true
    }
}

// MARK: - Player errors enum

enum PlayerError : Error {
    case FailToDecodePlayerError
}
