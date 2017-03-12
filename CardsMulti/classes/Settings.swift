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
    
    var minRank: Int {
        get {
            if let m = userDefaults.value(forKey: "minRank") as? Int {
                return m
            }
            userDefaults.setValue(defaultMinRank, forKey: "minRank")
            userDefaults.synchronize()
            return defaultMinRank
        }
        set(value) {
            userDefaults.setValue(value, forKey: "minRank")
            userDefaults.synchronize()
        }
    }
    
    var maxRank: Int {
        get {
            if let m = userDefaults.value(forKey: "maxRank") as? Int {
                return m
            }
            userDefaults.setValue(defaultMaxRank, forKey: "maxRank")
            userDefaults.synchronize()
            return defaultMaxRank
        }
        set(value) {
            userDefaults.setValue(value, forKey: "maxRank")
            userDefaults.synchronize()
        }
    }
    
    var pips: Bool {
        get {
            if let m = userDefaults.value(forKey: "pips") as? Bool {
                return m
            }
            userDefaults.setValue(true, forKey: "pips")
            userDefaults.synchronize()
            return true
        }
        set(value) {
            userDefaults.setValue(value, forKey: "pips")
            userDefaults.synchronize()
        }
    }
    
    var jack: Bool {
        get {
            if let m = userDefaults.value(forKey: "jack") as? Bool {
                return m
            }
            userDefaults.setValue(true, forKey: "jack")
            userDefaults.synchronize()
            return true
        }
        set(value) {
            userDefaults.setValue(value, forKey: "jack")
            userDefaults.synchronize()
        }
    }
    
    var queen: Bool {
        get {
            if let m = userDefaults.value(forKey: "queen") as? Bool {
                return m
            }
            userDefaults.setValue(true, forKey: "queen")
            userDefaults.synchronize()
            return true
        }
        set(value) {
            userDefaults.setValue(value, forKey: "queen")
            userDefaults.synchronize()
        }
    }
    
    var king: Bool {
        get {
            if let m = userDefaults.value(forKey: "king") as? Bool {
                return m
            }
            userDefaults.setValue(true, forKey: "king")
            userDefaults.synchronize()
            return true
        }
        set(value) {
            userDefaults.setValue(value, forKey: "king")
            userDefaults.synchronize()
        }
    }
    
    var ace: Bool {
        get {
            if let m = userDefaults.value(forKey: "ace") as? Bool {
                return m
            }
            userDefaults.setValue(true, forKey: "ace")
            userDefaults.synchronize()
            return true
        }
        set(value) {
            userDefaults.setValue(value, forKey: "ace")
            userDefaults.synchronize()
        }
    }
    
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(minRank, forKey: "minRank")
        aCoder.encode(maxRank, forKey: "maxRank")
        aCoder.encode(jack, forKey: "jack")
        aCoder.encode(queen, forKey: "queen")
        aCoder.encode(king, forKey: "king")
        aCoder.encode(ace, forKey: "ace")
    }
}
