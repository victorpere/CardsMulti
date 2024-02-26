//
//  GameState.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-28.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

class GameState {
    
    // MARK: - Singleton
    
    static let instance = GameState()
    
    // MARK: - Properties
    
    private let gameType: GameType?
    
    @StoredEncodedWithDefault var cardNodes: [CardSpriteNode]
    @StoredEncodedWithDefault var scores: [Score]
    @StoredValue (key: "gameId") var gameId: String?
    
    // MARK: - Computed properties
    
    var gameTypeId: String {
        if let gameTypeId = self.gameType?.rawValue {
            return String(gameTypeId)
        }
        return ""
    }
    
    // MARK: - Initializers
    
    init() {
        _cardNodes = StoredEncodedWithDefault(key: "_cardNodes", defaultValue: [])
        _scores = StoredEncodedWithDefault(key: "_scores", defaultValue: [])

        self.gameType = nil
    }
    
    init(_ gameType: GameType) {
        _cardNodes = StoredEncodedWithDefault(key: "\(gameType.rawValue)_cardNodes", defaultValue: [])
        _scores = StoredEncodedWithDefault(key: "\(gameType.rawValue)_scores", defaultValue: [])
        
        self.gameType = gameType
    }
}
