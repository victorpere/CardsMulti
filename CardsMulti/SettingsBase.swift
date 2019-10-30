//
//  SettingsBase.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-28.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

class SettingsBase : NSObject {
    let userDefaults = UserDefaults.standard
    
    func setting<T>(forKey key: String) throws -> T {
        if let value = self.userDefaults.value(forKey: key) as? T {
            return value
        }
        throw SettingsErrors.settingNotFound
    }
    
    func settingOrDefault<T>(forKey key: String, defaultValue: T) -> T {
        if let value = self.userDefaults.value(forKey: key) as? T {
            return value
        }
        self.setSetting(forKey: key, toValue: defaultValue)
        return defaultValue
    }
    
    func setSetting<T>(forKey key: String, toValue value: T) {
        self.userDefaults.setValue(value, forKey: key)
        self.userDefaults.synchronize()
    }
}
