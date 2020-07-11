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
}
