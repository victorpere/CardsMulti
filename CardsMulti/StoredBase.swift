//
//  SettingsBase.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-28.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

class StoredBase : NSObject {
    let userDefaults = UserDefaults.standard
    
    func setting<T>(forKey key: String) -> T? {
        if let value = self.userDefaults.object(forKey: key) as? T {
            return value
        }
        return nil
    }
    
    func settingOrDefault<T>(forKey key: String, defaultValue: T) -> T {
        if let value = self.userDefaults.object(forKey: key) as? T {
            return value
        }
        self.setSetting(forKey: key, toValue: defaultValue)
        return defaultValue
    }
    
    func setSetting<T>(forKey key: String, toValue value: T?) {
        guard let value = value else { return }
        self.userDefaults.set(value, forKey: key)
    }
    
    func removeSetting(forKey key: String) {
        self.userDefaults.removeObject(forKey: key)
    }
}
