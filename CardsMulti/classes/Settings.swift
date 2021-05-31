//
//  Settings.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class Settings : SettingsBase, NSCoding {
    
    // MARK: - Singleton
    
    static let instance = Settings()
    
    // MARK: - Defaults
    
    static let defaultMinRank = 2
    static let defaultMaxRank = 10
    
    static let defaultCardWidthsPerScreen: Float = 6
    static let minCardWidthsPerScreen: Float = 3
    static let maxCardWidthsPerScreen: Float = 10
    
    static let gameConfig = [
        GameType.Solitare : [
            "minRank" : 2,
            "maxRank" : 10,
            "pips" : true,
            "jack" : true,
            "queen" : true,
            "king" : true,
            "ace" : true,
            "cardWidthsPerScreen" : 8
        ]
    ]

    
    // MARK: - Properties
    
    var displayName: String {
        get {
            return self.settingOrDefault(forKey: "displayName", defaultValue: UIDevice.current.name)
        }
        set(value) {
            self.setSetting(forKey: "displayName", toValue: value)
        }
    }
    
    var game: Int {
        get {
            return self.settingOrDefault(forKey: "game", defaultValue: GameType.FreePlay.rawValue)
        }
        set(value) {
            self.setSetting(forKey: "game", toValue: value)
        }
    }
    
    var minRank: Int {
        get {
            if let gameConfig = Settings.gameConfig[GameType(rawValue: self.game)!] {
                if let setting = gameConfig["minRank"] {
                    return setting as! Int
                }
            }
            return self.settingOrDefault(forKey: "minRank", defaultValue: Settings.defaultMinRank)
        }
        set(value) {
            self.setSetting(forKey: "minRank", toValue: value)
        }
    }
    
    var maxRank: Int {
        get {
            return self.settingOrDefault(forKey: "maxRank", defaultValue: Settings.defaultMaxRank)
        }
        set(value) {
            self.setSetting(forKey: "maxRank", toValue: value)
        }
    }
    
    var pips: Bool {
        get {
            return self.settingOrDefault(forKey: "pips", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "pips", toValue: value)
        }
    }
    
    var jack: Bool {
        get {
            return self.settingOrDefault(forKey: "jack", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "jack", toValue: value)
        }
    }
    
    var queen: Bool {
        get {
            return self.settingOrDefault(forKey: "queen", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "queen", toValue: value)
        }
    }
    
    var king: Bool {
        get {
            return self.settingOrDefault(forKey: "king", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "king", toValue: value)
        }
    }
    
    var ace: Bool {
        get {
            return self.settingOrDefault(forKey: "ace", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "ace", toValue: value)
        }
    }
    
    var cardWidthsPerScreen: Float {
        get {
            return self.settingOrDefault(forKey: "cardWidthsPerScreen", defaultValue: Settings.defaultCardWidthsPerScreen)
        }
        set(value) {
            self.setSetting(forKey: "cardWidthsPerScreen", toValue: value)
        }
    }
    
    var soundOn: Bool {
        get {
            return self.settingOrDefault(forKey: "soundOn", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "soundOn", toValue: value)
        }
    }
    
    // MARK: - Computed properties
    
    var settingsDictionary: NSDictionary {
        return NSDictionary(dictionary: [
            SettingsKey.game.rawValue : self.game,
            SettingsKey.minRank.rawValue : self.minRank,
            SettingsKey.maxRank.rawValue : self.maxRank,
            SettingsKey.pips.rawValue : self.pips,
            SettingsKey.jack.rawValue : self.jack,
            SettingsKey.queen.rawValue : self.queen,
            SettingsKey.king.rawValue : self.king,
            SettingsKey.ace.rawValue : self.ace,
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
            self.jack = value
        }
        if let value = aDecoder.decodeObject(forKey: "queen") as? Bool {
            self.queen = value
        }
        if let value = aDecoder.decodeObject(forKey: "king") as? Bool {
            self.king = value
        }
        if let value = aDecoder.decodeObject(forKey: "ace") as? Bool {
            self.ace = value
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
            self.pips = value
        }
        if let value = settingsDictionary[SettingsKey.jack.rawValue] as? Bool {
            self.jack = value
        }
        if let value = settingsDictionary[SettingsKey.queen.rawValue] as? Bool {
            self.queen = value
        }
        if let value = settingsDictionary[SettingsKey.king.rawValue] as? Bool {
            self.king = value
        }
        if let value = settingsDictionary[SettingsKey.ace.rawValue] as? Bool {
            self.ace = value
        }
        if let value = settingsDictionary[SettingsKey.cardWidthsPerScreen] as? Float {
            self.cardWidthsPerScreen = value
        }
    }
    
    // MARK: - NSCoding methods
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.game, forKey: "game")
        aCoder.encode(self.minRank, forKey: "minRank")
        aCoder.encode(self.maxRank, forKey: "maxRank")
        aCoder.encode(self.jack, forKey: "jack")
        aCoder.encode(self.queen, forKey: "queen")
        aCoder.encode(self.king, forKey: "king")
        aCoder.encode(self.ace, forKey: "ace")
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
}
