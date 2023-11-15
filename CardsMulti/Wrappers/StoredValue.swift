//
//  StoredValue.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-02.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation

@propertyWrapper struct StoredValue<T> {
    let key: String
    
    var wrappedValue: T? {
        get { UserDefaults.standard.object(forKey: self.key) as? T}
        set { UserDefaults.standard.set(newValue, forKey: self.key)}
    }
}

@propertyWrapper struct StoredWithDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get { (UserDefaults.standard.object(forKey: self.key) as? T) ?? self.defaultValue}
        set { UserDefaults.standard.set(newValue, forKey: self.key)}
    }
}
