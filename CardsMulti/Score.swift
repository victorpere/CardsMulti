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

class Score: Codable {
    
    // MARK: - Properties
    
    /// Peer ID of the player that the score belongs to
    var peerId: MCPeerID?
    
    /// Name of the score
    var name: String!
    
    /// Value of the score
    var score: Double = 0
    
    /// A string to be displayed precedign the score value
    var prefix: String = ""
    
    /// A string to be displayed following the score value
    var suffix: String = ""
    
    /// Game type that the score belongs to
    var gameType: GameType!
    
    /// Number of decimal places to be displayed
    var decimalPlaces: Int = 0
    
    /// The name of the score to be displayed
    var displayName: String?
    
    /// The game scene label that is attached to the score
    var label: SKLabelNode?
    
    /// List of scores with a string description and a numeric value
    var scores: [(String,Double)?]
    
    // MARK: - Computed properties
    
    /// Unique identifier of the score usig the peer ID display name, game type and score name
    var scoreId: String {
        return "score_\(self.peerId?.displayName ?? "")_\(self.gameType.rawValue)_\(self.name ?? "")"
    }
    
    var truncatedScoreText: String {
        if self.decimalPlaces == 0 {
            return String(Int(self.score))
        }
        return String(self.score.truncate(places: self.decimalPlaces))
    }
    
    var scoreText: String {
        return "\(self.displayName ?? "")\n\(self.prefix)\(self.truncatedScoreText)\(self.suffix)"
    }
    
    var scoreTotal: Double {
        var total: Double = 0
        for score in self.scores {
            if score != nil {
                total += score!.1
            }
        }
        return total
    }
    
    // MARK: - Decode/Encode
    
    private enum CodingKeys: String, CodingKey {
        case peerId
        case name
        case score
        case prefix
        case suffix
        case gameType
    }
    
    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        self.peerId = MCPeerID(displayName: try values.decode(String.self, forKey: .peerId))
        self.name = try values.decode(String.self, forKey: .name)
        self.score = try values.decode(Double.self, forKey: .score)
        self.prefix = try values.decode(String.self, forKey: .prefix)
        self.suffix = try values.decode(String.self, forKey: .suffix)
        self.gameType = try values.decode(GameType.self, forKey: .gameType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.peerId?.displayName ?? "", forKey: .peerId)
        try container.encode(self.name ?? "", forKey: .name)
        try container.encode(self.score, forKey: .score)
        try container.encode(self.prefix, forKey: .prefix)
        try container.encode(self.suffix, forKey: .suffix)
        try container.encode(self.gameType, forKey: .gameType)
    }
    
    // MARK: - Initializers
    
    convenience init(peerId: MCPeerID, gameType: GameType) {
        self.init()
        self.peerId = peerId
        self.gameType = gameType
    }

    convenience init(peerId: MCPeerID, name: String, gameType: GameType) {
        self.init()
        self.peerId = peerId
        self.name = name
        self.gameType = gameType
    }
    
    convenience init(peerId: MCPeerID, name: String, prefixUnit: String, gameType: GameType) {
        self.init()
        self.peerId = peerId
        self.name = name
        self.prefix = prefixUnit
        self.gameType = gameType
    }
    
    convenience init(peerId: MCPeerID, name: String, suffixUnit: String, gameType: GameType) {
        self.init()
        self.peerId = peerId
        self.name = name
        self.suffix = suffixUnit
        self.gameType = gameType
    }
    
    private init() {
        self.scores = [(String,Double)?](repeating: nil, count: 1000)
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
