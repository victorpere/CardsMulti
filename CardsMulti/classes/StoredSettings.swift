//
//  Settings.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class StoredSettings : StoredBase, Settings, NSCoding {
    
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
    
    @StoredWithDefault (key: "soundOn", defaultValue: true) var soundOn: Bool
    @StoredValue (key: "customOptions") var customOptions: NSDictionary?
    
    // TODO: replace with CardDeck
    var minRank: Int {
        get {
            return self.settingOrDefault(forKey: "minRank", defaultValue: StoredSettings.defaultMinRank)
        }
        set(value) {
            self.setSetting(forKey: "minRank", toValue: value)
        }
    }
    
    var maxRank: Int {
        get {
            return self.settingOrDefault(forKey: "maxRank", defaultValue: StoredSettings.defaultMaxRank)
        }
        set(value) {
            self.setSetting(forKey: "maxRank", toValue: value)
        }
    }
    
    var pipsEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "pips", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "pips", toValue: value)
        }
    }
    
    var jacksEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "jack", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "jack", toValue: value)
        }
    }
    
    var queensEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "queen", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "queen", toValue: value)
        }
    }
    
    var kingsEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "king", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "king", toValue: value)
        }
    }
    
    var acesEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "ace", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "ace", toValue: value)
        }
    }
    
    // TODO: use StoredWithDefault
    var margin: Float {
        get {
            let config = GameConfigs.sharedInstance.gameConfig(for: GameType(rawValue: self.game))
            return config?.defaultSettings.margin ?? GameConfigs.sharedInstance.defaultSettings.margin
        }
        set(value) {
            self.setSetting(forKey: "margin", toValue: value)
        }
    }
    
    // MARK: - Computed properties
    
    var settingsDictionary: NSDictionary {
        return NSDictionary(dictionary: [
            SettingsKey.game.rawValue : self.game,
            SettingsKey.minRank.rawValue : self.minRank,
            SettingsKey.maxRank.rawValue : self.maxRank,
            SettingsKey.pips.rawValue : self.pipsEnabled,
            SettingsKey.jack.rawValue : self.jacksEnabled,
            SettingsKey.queen.rawValue : self.queensEnabled,
            SettingsKey.king.rawValue : self.kingsEnabled,
            SettingsKey.ace.rawValue : self.acesEnabled,
            SettingsKey.cardWidthsPerScreen.rawValue : self.cardWidthsPerScreen
        ])
    }
    
    // MARK: - Initializers
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        if let value = aDecoder.decodeObject(forKey: "game") as? Int {
            self.game = value
        }
        if let value = aDecoder.decodeObject(forKey: "minRank") as? Int {
            self.minRank = value
        }
        if let value = aDecoder.decodeObject(forKey: "minRank") as? Int {
            self.maxRank = value
        }
        if let value = aDecoder.decodeObject(forKey: "jack") as? Bool {
            self.jacksEnabled = value
        }
        if let value = aDecoder.decodeObject(forKey: "queen") as? Bool {
            self.queensEnabled = value
        }
        if let value = aDecoder.decodeObject(forKey: "king") as? Bool {
            self.kingsEnabled = value
        }
        if let value = aDecoder.decodeObject(forKey: "ace") as? Bool {
            self.acesEnabled = value
        }
        if let value = aDecoder.decodeObject(forKey: "cardWidthsPerScreen") as? Float {
            self.cardWidthsPerScreen = value
        }
    }
    
    init(with data: Data) throws {
        super.init()
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
        super.init()
        
        self.initialize(withDictionary: settingsDictionary)
    }
    
    // MARK: - Public methods
    
    func jsonData() throws -> Data {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.settingsDictionary)
            return jsonData
        } catch {
            throw SettingsErrors.FailedToEncodeSettings
        }
    }
    
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
        if let value = settingsDictionary[SettingsKey.minRank.rawValue] as? Int {
            self.minRank = value
        }
        if let value = settingsDictionary[SettingsKey.maxRank.rawValue] as? Int {
            self.maxRank = value
        }
        if let value = settingsDictionary[SettingsKey.pips.rawValue] as? Bool {
            self.pipsEnabled = value
        }
        if let value = settingsDictionary[SettingsKey.jack.rawValue] as? Bool {
            self.jacksEnabled = value
        }
        if let value = settingsDictionary[SettingsKey.queen.rawValue] as? Bool {
            self.queensEnabled = value
        }
        if let value = settingsDictionary[SettingsKey.king.rawValue] as? Bool {
            self.kingsEnabled = value
        }
        if let value = settingsDictionary[SettingsKey.ace.rawValue] as? Bool {
            self.acesEnabled = value
        }
        if let value = settingsDictionary[SettingsKey.cardWidthsPerScreen.rawValue] as? Float {
            self.cardWidthsPerScreen = value
        }
    }
    
    // MARK: - NSCoding methods
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.game, forKey: "game")
        aCoder.encode(self.minRank, forKey: "minRank")
        aCoder.encode(self.maxRank, forKey: "maxRank")
        aCoder.encode(self.jacksEnabled, forKey: "jack")
        aCoder.encode(self.queensEnabled, forKey: "queen")
        aCoder.encode(self.kingsEnabled, forKey: "king")
        aCoder.encode(self.acesEnabled, forKey: "ace")
        aCoder.encode(self.cardWidthsPerScreen, forKey: "cardWidthsPerScreen")
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
}
