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
            if let m = self.userDefaults.value(forKey: "minRank") as? Int {
                return m
            }
            self.userDefaults.setValue(defaultMinRank, forKey: "minRank")
            self.userDefaults.synchronize()
            return self.defaultMinRank
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "minRank")
            self.userDefaults.synchronize()
        }
    }
    
    var maxRank: Int {
        get {
            if let m = self.userDefaults.value(forKey: "maxRank") as? Int {
                return m
            }
            self.userDefaults.setValue(defaultMaxRank, forKey: "maxRank")
            self.userDefaults.synchronize()
            return self.defaultMaxRank
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "maxRank")
            self.userDefaults.synchronize()
        }
    }
    
    var pips: Bool {
        get {
            if let m = self.userDefaults.value(forKey: "pips") as? Bool {
                return m
            }
            self.userDefaults.setValue(true, forKey: "pips")
            self.userDefaults.synchronize()
            return true
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "pips")
            self.userDefaults.synchronize()
        }
    }
    
    var jack: Bool {
        get {
            if let m = self.userDefaults.value(forKey: "jack") as? Bool {
                return m
            }
            self.userDefaults.setValue(true, forKey: "jack")
            self.userDefaults.synchronize()
            return true
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "jack")
            self.userDefaults.synchronize()
        }
    }
    
    var queen: Bool {
        get {
            if let m = self.userDefaults.value(forKey: "queen") as? Bool {
                return m
            }
            self.userDefaults.setValue(true, forKey: "queen")
            self.userDefaults.synchronize()
            return true
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "queen")
            self.userDefaults.synchronize()
        }
    }
    
    var king: Bool {
        get {
            if let m = self.userDefaults.value(forKey: "king") as? Bool {
                return m
            }
            self.userDefaults.setValue(true, forKey: "king")
            self.userDefaults.synchronize()
            return true
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "king")
            self.userDefaults.synchronize()
        }
    }
    
    var ace: Bool {
        get {
            if let m = self.userDefaults.value(forKey: "ace") as? Bool {
                return m
            }
            self.userDefaults.setValue(true, forKey: "ace")
            self.userDefaults.synchronize()
            return true
        }
        set(value) {
            self.userDefaults.setValue(value, forKey: "ace")
            self.userDefaults.synchronize()
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
