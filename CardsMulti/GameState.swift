//
//  GameState.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-28.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

class GameState : SettingsBase {
    
    // MARK: - Singleton
    
    static let instance = GameState()
    static let solitare = GameState(.Solitare)
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    init(_ gameType: GameType) {
        super.init()
        self.gameType = gameType
    }
    
    // MARK: - Properties
    
    var gameType: GameType?
    
    // MARK: - Stored properties
    
    var cardNodes: [CardSpriteNode] {
        get {
            let cardSymbols = self.settingOrDefault(forKey: "cardSymbols", defaultValue: NSArray())
            var cardNodes: [CardSpriteNode] = []
            for cardSymbol in cardSymbols {
                let cardInfo = self.settingOrDefault(forKey: cardSymbol as! String, defaultValue: NSDictionary())
                cardNodes.append(CardSpriteNode(cardInfo: cardInfo))
            }
            return cardNodes
        }
        set(value) {
            let cardSymbols = NSArray(array: value.map { $0.card?.symbol() as Any })
            self.setSetting(forKey: "cardSymbols", toValue: cardSymbols)
            for cardNode in value {
                let cardInfo = cardNode.cardInfo
                self.setSetting(forKey: (cardNode.card?.symbol())!, toValue: cardInfo)
            }
        }
    }
    
    var scores: [Score] {
        get {
            let scoreIds = self.settingOrDefault(forKey: "scores", defaultValue: NSArray())
            var scores: [Score] = []
            for scoreId in scoreIds {
                let scoreInfo = self.settingOrDefault(forKey: scoreId as! String, defaultValue: NSDictionary())
                scores.append(Score(scoreInfo: scoreInfo))
            }
            return scores
        }
        set(value) {
            let scoreIds = NSArray(array: value.map { $0.scoreId as Any })
            self.setSetting(forKey: "scores", toValue: scoreIds)
            for score in value {
                self.setSetting(forKey: score.scoreId, toValue: score.scoreInfo)
            }
        }
    }
}
