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
    
    // MARK: - Properties
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
}
