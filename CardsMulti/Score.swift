//
//  Score.swift
//  CardsMulti
//
//  Created by Victor on 2020-03-09.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import GameKit

class Score {
    
    // MARK: - Properties
    
    var peerId: MCPeerID?
    var name: String!
    var score: Double = 0
    var prefix: String = ""
    var suffix: String = ""
    var gameType: GameType!
    var decimalPlaces: Int = 0
    var displayName: String?
    var label: SKLabelNode?
    
    // MARK: - Computed properties
    
    var scoreInfo: NSDictionary {
        get {
            return NSDictionary(dictionary: [
                "peerId": self.peerId?.displayName ?? "",
                "name": self.name ?? "",
                "score": self.score,
                "prefix": self.prefix ,
                "suffix": self.suffix ,
                "gameType": self.gameType.rawValue 
            ])
        }
    }
    
    var scoreId: String {
        get {
            return "score_\(self.peerId?.displayName ?? "")_\(self.gameType.rawValue)_\(self.name ?? "")"
        }
    }
    
    var truncatedScoreText: String {
        get {
            if self.decimalPlaces == 0 {
                return String(Int(self.score))
            }
            return String(self.score.truncate(places: self.decimalPlaces))
        }
    }
    
    var scoreText: String {
        get {
            return "\(self.displayName ?? "")\n\(self.prefix)\(self.truncatedScoreText)\(self.suffix)"
        }
    }
    
    // MARK: - Initializers
    
    init(scoreInfo: NSDictionary) {
        if let value = scoreInfo["peerId"] as? String {
            self.peerId = MCPeerID(displayName: value)
        }
        
        if let value = scoreInfo["name"] as? String {
            self.name = value
        } else {
            self.name = ""
        }
        
        if let value = scoreInfo["score"] as? Double {
            self.score = value
        } else {
            self.score = 0
        }
        
        if let value = scoreInfo["prefix"] as? String {
            self.prefix = value
        } else {
            self.prefix = ""
        }
        
        if let value = scoreInfo["suffix"] as? String {
            self.suffix = value
        } else {
            self.suffix = ""
        }
        
        if let value = scoreInfo["gameType"] as? Int {
            self.gameType = GameType(rawValue: value)
        } else {
            self.gameType = .FreePlay
        }
    }
    
    init(peerId: MCPeerID, gameType: GameType) {
        self.peerId = peerId
        self.gameType = gameType
    }

    init(peerId: MCPeerID, name: String, gameType: GameType) {
        self.peerId = peerId
        self.name = name
        self.gameType = gameType
    }
    
    init(peerId: MCPeerID, name: String, prefixUnit: String, gameType: GameType) {
        self.peerId = peerId
        self.name = name
        self.prefix = prefixUnit
        self.gameType = gameType
    }
    
    init(peerId: MCPeerID, name: String, suffixUnit: String, gameType: GameType) {
        self.peerId = peerId
        self.name = name
        self.suffix = suffixUnit
        self.gameType = gameType
    }
    
    // MARK: - Public methods
    
    /**
     Resets the score to zero
     */
    func reset() {
        self.score = 0
        if let label = self.label {
            label.text = self.scoreText
        }
    }
}
