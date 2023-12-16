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
        
        let defaultSettings = GameConfigs.sharedInstance.gameConfig(for: gameType)?.defaultSettings
        
        _deck = StoredEncodedWithDefault(key: "\(gameType.rawValue)deck", defaultValue: defaultSettings?.deck ?? CardDeck.empty)
        _cardWidthsPerScreen = StoredWithDefault(key: "\(gameType.rawValue)\(SettingsKey.cardWidthsPerScreen)", defaultValue: defaultSettings?.cardWidthsPerScreen ?? Config.defaultCardWidthsPerScreen)
        _margin = StoredWithDefault(key: "\(gameType.rawValue)\(SettingsKey.margin)", defaultValue: defaultSettings?.margin ?? Config.defaultMargin)
        
        _customOptions = StoredValue(key: "\(gameType.rawValue)\(SettingsKey.customOptions )")
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
