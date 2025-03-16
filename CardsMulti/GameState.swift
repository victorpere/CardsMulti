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
    private var previousSceneStates: [SceneState] = []
    
    @StoredEncodedWithDefault var sceneState: SceneState
    @StoredValue (key: "gameId") var gameId: String?
    
    // MARK: - Computed properties
    
    var gameTypeId: String {
        if let gameTypeId = self.gameType?.rawValue {
            return String(gameTypeId)
        }
        return ""
    }
    
    var undoAvailable: Bool {
        return self.previousSceneStates.count > 0
    }
    
    // MARK: - Initializers
    
    init() {
        @StoredEncodedWithDefault var cardNodes: [CardSpriteNode]
        _cardNodes = StoredEncodedWithDefault(key: "_cardNodes", defaultValue: [])
        @StoredEncodedWithDefault var scores: [Score]
        _scores = StoredEncodedWithDefault(key: "_scores", defaultValue: [])

        self.gameType = nil
        
        let sceneState = SceneState(cardNodes: cardNodes, scores: scores)
        _sceneState = StoredEncodedWithDefault(key: "_sceneState", defaultValue: sceneState)
    }
    
    init(_ gameType: GameType) {
        @StoredEncodedWithDefault var cardNodes: [CardSpriteNode]
        _cardNodes = StoredEncodedWithDefault(key: "\(gameType.rawValue)_cardNodes", defaultValue: [])
        @StoredEncodedWithDefault var scores: [Score]
        _scores = StoredEncodedWithDefault(key: "\(gameType.rawValue)_scores", defaultValue: [])
        
        self.gameType = gameType
        
        let sceneState = SceneState(cardNodes: cardNodes, scores: scores)
        _sceneState = StoredEncodedWithDefault(key: "\(gameType.rawValue)_sceneState", defaultValue: sceneState)
    }
    
    // MARK: - Public methods
    
    /**
     Save cards an scores to the current game state
     
     - parameters:
        - cardNodes: cards to save
        - scores: scores to save
     */
    func save(cardNodes: [CardSpriteNode], scores: [Score], clearUndo: Bool = false, saveToUndo: Bool = true) {
        if clearUndo {
            self.previousSceneStates = []
        }
        
        if saveToUndo {
            self.previousSceneStates.append(self.sceneState)
        }
        
        self.sceneState = SceneState(cardNodes: cardNodes, scores: scores)
    }
    
    /**
     Revert to the previous game state
     */
    func undo() {
        if self.previousSceneStates.count > 0, let previousSceneState = self.previousSceneStates.popLast() {
            self.sceneState = previousSceneState
        }
    }
    
    func clearUndo() {
        self.previousSceneStates = []
    }
}
