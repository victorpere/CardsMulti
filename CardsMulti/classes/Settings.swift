//
//  Settings.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import Foundation

class Settings : NSObject, NSCoding {
    let userDefaults = UserDefaults.standard
    let defaultMinRank = 2
    let defaultMaxRank = 10
    
    // MARK: - Properties
    
    var minRank: Int {
        get {
            return self.settingOrDefault(forKey: "minRank", defaultValue: self.defaultMinRank)
        }
        set(value) {
            self.setSetting(forKey: "minRank", toValue: value)
        }
    }
    
    var maxRank: Int {
        get {
            return self.settingOrDefault(forKey: "maxRank", defaultValue: self.defaultMaxRank)
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
    
    // MARK: - Initializers
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
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
    }
    
    // MARK: - NSCoding methods
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(minRank, forKey: "minRank")
        aCoder.encode(maxRank, forKey: "maxRank")
        aCoder.encode(jack, forKey: "jack")
        aCoder.encode(queen, forKey: "queen")
        aCoder.encode(king, forKey: "king")
        aCoder.encode(ace, forKey: "ace")
    }
    
    // MARK: - Private functions
    
    private func setting<T>(forKey key: String) throws -> T {
        if let value = self.userDefaults.value(forKey: key) as? T {
            return value
        }
        throw SettingsErrors.settingNotFound
    }
    
    private func settingOrDefault<T>(forKey key: String, defaultValue: T) -> T {
        if let value = self.userDefaults.value(forKey: key) as? T {
            return value
        }
        self.setSetting(forKey: key, toValue: defaultValue)
        return defaultValue
    }
    
    private func setSetting<T>(forKey key: String, toValue value: T) {
        self.userDefaults.setValue(value, forKey: key)
        self.userDefaults.synchronize()
    }
}

// MARK: - Protocol SettingsErrors

enum SettingsErrors : Error {
    case settingNotFound
}
