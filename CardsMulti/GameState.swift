//
//  GameState.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-28.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

class GameState : StoredBase {
    
    // MARK: - Singleton
    
    static let instance = GameState()
    
    // MARK: - Properties
    
    var gameType: GameType?
    
    @StoredEncodedWithDefault var cardNodes: [CardSpriteNode]
    @StoredEncodedWithDefault var scores: [Score]
    
    // MARK: - Initializers
    
    override init() {
        _cardNodes = StoredEncodedWithDefault(key: "_cardNodes", defaultValue: [])
        _scores = StoredEncodedWithDefault(key: "_scores", defaultValue: [])
        
        super.init()
    }
    
    init(_ gameType: GameType) {
        _cardNodes = StoredEncodedWithDefault(key: "\(gameType.rawValue)_cardNodes", defaultValue: [])
        _scores = StoredEncodedWithDefault(key: "\(gameType.rawValue)_scores", defaultValue: [])
        
        super.init()
        self.gameType = gameType
    }
    
    
    // MARK: - Enums
    
    fileprivate enum Key : String {
        case cardSymbols = "cardSymbols"
        case scores = "scores"
        case gameId = "gameId"
    }
    
    // MARK: - Stored properties
    
    var gameTypeId: String {
        if let gameTypeId = self.gameType?.rawValue {
            return String(gameTypeId)
        }
        return ""
    }
    
    var gameId: String? {
        get {
            return self.settingOrDefault(forKey: Key.gameId.rawValue, defaultValue: nil)
        }
        set(value) {
            if value != nil {
                self.setSetting(forKey: Key.gameId.rawValue, toValue: value)
            } else {
                self.removeSetting(forKey: Key.gameId.rawValue)
            }
        }
    }
}
