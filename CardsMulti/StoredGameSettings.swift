//
//  StoredGameSettings.swift
//  CardsMulti
//
//  Created by Victor on 2021-08-31.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class StoredGameSettings : GameSettings {

    // MARK: - Properties
    
    let gameType: GameType
    
    @StoredEncodedWithDefault var deck: CardDeck
    @StoredWithDefault var cardWidthsPerScreen: Float
    @StoredWithDefault var margin: Float
    
    @StoredValue var customOptions: NSDictionary?
    
    // MARK: - initializer
    
    init(with gameType: GameType) {
        self.gameType = gameType
        
        _deck = StoredEncodedWithDefault(key: "\(gameType.rawValue)deck", defaultValue: CardDeck.empty)
        _cardWidthsPerScreen = StoredWithDefault(key: "\(self.gameType.rawValue)\(SettingsKey.cardWidthsPerScreen)", defaultValue: Config.defaultCardWidthsPerScreen)
        _margin = StoredWithDefault(key: "\(self.gameType.rawValue)\(SettingsKey.margin)", defaultValue: 0)
        
        _customOptions = StoredValue(key: "\(self.gameType.rawValue)\(SettingsKey.customOptions )")
    }
    
    // MARK: - Public methods
    
    func sync(to gameSettings: GameSettings) {
        self.cardWidthsPerScreen = gameSettings.cardWidthsPerScreen
        self.margin = gameSettings.margin
        self.customOptions = gameSettings.customOptions
        self.deck = gameSettings.deck
    }
    
    func sync(toSettings settings: Settings) {
        self.cardWidthsPerScreen = settings.cardWidthsPerScreen
        self.margin = settings.margin
        self.customOptions = settings.customOptions
        self.deck = settings.deck
    }
    
    func equals(to gameSettings: GameSettings) -> Bool {
        return gameSettings.deck == self.deck
    }
}
