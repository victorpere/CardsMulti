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

@propertyWrapper struct StoredEncodedValue<T: Codable> {
    let key: String
    
    var wrappedValue: T? {
        get {
            if let data = UserDefaults.standard.data(forKey: self.key) {
                let jsonDecoder = JSONDecoder()
                return try? jsonDecoder.decode(T.self, from: data)
            }
            return nil
        }
        set {
            let jsonEncoder = JSONEncoder()
            if let data = try? jsonEncoder.encode(newValue) {
                UserDefaults.standard.set(data, forKey: self.key)
            }
        }
    }
}
