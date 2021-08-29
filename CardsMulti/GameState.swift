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
    static let solitare = GameState(.solitare)
    
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
    
    var cardNodes: [CardSpriteNode] {
        get {
            let cardSymbols = self.settingOrDefault(forKey: "\(self.gameTypeId)\(Key.cardSymbols.rawValue)", defaultValue: NSArray())
            var cardNodes: [CardSpriteNode] = []
            for cardSymbol in cardSymbols {
                let cardInfo = self.settingOrDefault(forKey: "\(self.gameTypeId)\(cardSymbol as! String)", defaultValue: NSDictionary())
                if cardInfo.allKeys.count > 0 {
                    cardNodes.append(CardSpriteNode(cardInfo: cardInfo))
                }
            }
            return cardNodes
        }
        set(value) {
            let cardSymbols = NSArray(array: value.map { $0.card.symbol as Any })
            self.setSetting(forKey: "\(self.gameTypeId)\(Key.cardSymbols.rawValue)", toValue: cardSymbols)
            for cardNode in value {
                let cardInfo = cardNode.cardInfo
                self.setSetting(forKey: "\(self.gameTypeId)\(cardNode.card.symbol)", toValue: cardInfo)
            }
        }
    }
    
    var scores: [Score] {
        get {
            let scoreIds = self.settingOrDefault(forKey: "\(self.gameTypeId)\(Key.scores.rawValue)", defaultValue: NSArray())
            var scores: [Score] = []
            for scoreId in scoreIds {
                
                let scoreInfo = self.settingOrDefault(forKey: "\(self.gameTypeId)\(scoreId as! String)", defaultValue: NSDictionary())
                scores.append(Score(scoreInfo: scoreInfo))
            }
            return scores
        }
        set(value) {
            let scoreIds = NSArray(array: value.map { $0.scoreId as Any })
            self.setSetting(forKey: "\(self.gameTypeId)\(Key.scores.rawValue)", toValue: scoreIds)
            for score in value {
                self.setSetting(forKey: "\(self.gameTypeId)\(score.scoreId)", toValue: score.scoreInfo)
            }
        }
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
