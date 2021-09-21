//
//  StoredGameSettings.swift
//  CardsMulti
//
//  Created by Victor on 2021-08-31.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class StoredGameSettings : StoredBase, GameSettings {

    // MARK: - Properties
    
    var gameType: GameType
    
    var minRank: Int {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.minRank)", defaultValue: StoredSettings.defaultMinRank)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.minRank)", toValue: value)
        }
    }
    
    var maxRank: Int {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.maxRank)", defaultValue: StoredSettings.defaultMaxRank)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.maxRank)", toValue: value)
        }
    }
    
    var pipsEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.pips)", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.pips)", toValue: value)
        }
    }
    
    var jacksEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.jack)", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.jack)", toValue: value)
        }
    }
    
    var queensEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.queen)", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.queen)", toValue: value)
        }
    }
    
    var kingsEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.king)", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.king)", toValue: value)
        }
    }
    
    var acesEnabled: Bool {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.ace)", defaultValue: true)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.ace)", toValue: value)
        }
    }
    
    var cardWidthsPerScreen: Float {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.cardWidthsPerScreen)", defaultValue: StoredSettings.defaultCardWidthsPerScreen)
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.cardWidthsPerScreen)", toValue: value)
        }
    }
    
    var customOptions: NSDictionary? {
        get {
            return self.settingOrDefault(forKey: "\(self.gameType.rawValue)\(SettingsKey.customOptions )", defaultValue: nil)
        }
        set(value) {
            if value != nil {
                self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.customOptions)", toValue: value)
            }
        }
    }
    
    var margin: Float {
        get {
            let config = GameConfigs.sharedInstance.gameConfig(for: self.gameType)
            return config?.defaultSettings.margin ?? GameConfigs.sharedInstance.defaultSettings.margin
        }
        set(value) {
            self.setSetting(forKey: "\(self.gameType.rawValue)\(SettingsKey.margin)", toValue: value)
        }
    }
    
    // MARK: - initializer
    
    init(with gameType: GameType) {
        self.gameType = gameType
    }
    
    // MARK: - Public methods
    
    func sync(to gameSettings: GameSettings) {
        self.minRank = gameSettings.minRank
        self.maxRank = gameSettings.maxRank
        self.pipsEnabled = gameSettings.pipsEnabled
        self.jacksEnabled = gameSettings.jacksEnabled
        self.queensEnabled = gameSettings.queensEnabled
        self.kingsEnabled = gameSettings.kingsEnabled
        self.acesEnabled = gameSettings.acesEnabled
        self.cardWidthsPerScreen = gameSettings.cardWidthsPerScreen
        self.margin = gameSettings.margin
        self.customOptions = gameSettings.customOptions
    }
    
    func sync(toSettings settings: Settings) {
        self.minRank = settings.minRank
        self.maxRank = settings.maxRank
        self.pipsEnabled = settings.pipsEnabled
        self.jacksEnabled = settings.jacksEnabled
        self.queensEnabled = settings.queensEnabled
        self.kingsEnabled = settings.kingsEnabled
        self.acesEnabled = settings.acesEnabled
        self.cardWidthsPerScreen = settings.cardWidthsPerScreen
        self.margin = settings.margin
        self.customOptions = settings.customOptions
    }
    
    func equals(to gameSettings: GameSettings) -> Bool {
        return gameSettings.minRank == self.minRank &&
            gameSettings.maxRank == self.maxRank &&
            gameSettings.pipsEnabled == self.pipsEnabled &&
            gameSettings.jacksEnabled == self.jacksEnabled &&
            gameSettings.queensEnabled == self.queensEnabled &&
            gameSettings.kingsEnabled == self.kingsEnabled &&
            gameSettings.acesEnabled == self.acesEnabled
    }
}
