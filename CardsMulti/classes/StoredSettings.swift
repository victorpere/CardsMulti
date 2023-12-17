//
//  Settings.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class StoredSettings : Settings {
    
    // MARK: - Singleton
    
    static let instance = StoredSettings()
    
    // MARK: - Defaults
    
    static let defaultMinRank = 2
    static let defaultMaxRank = 10
    
    // MARK: - Properties
    
    @StoredWithDefault (key: SettingsKey.displayName.rawValue, defaultValue: UIDevice.current.name) var displayName: String
    @StoredValue (key: "cardSet") var cardSet: String?
    @StoredWithDefault (key: SettingsKey.game.rawValue, defaultValue: GameType.freePlay.rawValue) var game: Int
    @StoredWithDefault (key: SettingsKey.cardWidthsPerScreen.rawValue, defaultValue: Config.defaultCardWidthsPerScreen) var cardWidthsPerScreen: Float
    
    @StoredWithDefault (key: "margin", defaultValue: Config.defaultMargin) var margin: Float
    @StoredWithDefault (key: "soundOn", defaultValue: true) var soundOn: Bool
    @StoredValue (key: "customOptions") var customOptions: NSDictionary?
    
    @StoredEncodedWithDefault (key: "deck", defaultValue: GameConfigs.sharedInstance.gameConfig(for: GameType.freePlay)?.defaultSettings.deck ?? CardDeck.empty) var deck: CardDeck
    

    var deckDictionary: NSDictionary? {
        if let data = try? JSONEncoder().encode(self.deck) {
            return try? JSONSerialization.jsonObject(with: data) as? NSDictionary
        }
        return nil
    }
    
    // MARK: - Computed properties
    
    var settingsDictionary: NSDictionary {
        return NSDictionary(dictionary: [
            SettingsKey.game.rawValue : self.game,
            SettingsKey.cardWidthsPerScreen.rawValue : self.cardWidthsPerScreen,
            SettingsKey.deck.rawValue : self.deckDictionary ?? ""
        ])
    }
    
    // MARK: - Initializers
    
    init() {}
    
    init(with data: Data) throws {
        do {
            if let settingsDictionary = try JSONSerialization.jsonObject(with: data) as? NSDictionary {
                
                self.initialize(withDictionary: settingsDictionary)
                
            } else {
                throw SettingsErrors.FailedToDecodeSettings
            }
        } catch {
            throw SettingsErrors.FailedToDecodeSettings
        }
    }
    
    init(withDictionary settingsDictionary: NSDictionary) {
        self.initialize(withDictionary: settingsDictionary)
    }
    
    // MARK: - Public methods
    
    func syncTo(settingsDictionary receivedSettingsDictionary: NSDictionary) {
        self.initialize(withDictionary: receivedSettingsDictionary)
        
        if let gameType = GameType.init(rawValue: self.game) {
            let gameSettings = StoredGameSettings(with: gameType)
            gameSettings.sync(toSettings: self)
        }
    }
    
    // MARK: - Private methods
    
    private func initialize(withDictionary settingsDictionary: NSDictionary) {
        if let value = settingsDictionary[SettingsKey.game.rawValue] as? Int {
            self.game = value
        }
        if let value = settingsDictionary[SettingsKey.cardWidthsPerScreen.rawValue] as? Float {
            self.cardWidthsPerScreen = value
        }
        if let value = settingsDictionary[SettingsKey.deck.rawValue] as? NSDictionary,
           let data = try? JSONSerialization.data(withJSONObject: value),
           let deck = try? JSONDecoder().decode(CardDeck.self, from: data) {
            self.deck = deck
        } else {
            self.deck = CardDeck.empty
        }
    }
}

// MARK: - Protocol SettingsErrors

enum SettingsErrors : Error {
    case settingNotFound
    case FailedToDecodeSettings
    case FailedToEncodeSettings
}

// MARK: - SettingsKey enum

enum SettingsKey : String {
    case displayName = "displayName"
    case game = "game"
    case minRank = "minRank"
    case maxRank = "maxRank"
    case pips = "pips"
    case jack = "jack"
    case queen = "queen"
    case king = "king"
    case ace = "ace"
    case cardWidthsPerScreen = "cardWidthsPerScreen"
    case margin = "margin"
    case customOptions = "customOptions"
    case deck = "deck"
}
