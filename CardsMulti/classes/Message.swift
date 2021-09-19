//
//  Message.swift
//  CardsMulti
//
//  Created by Victor on 2021-09-06.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation
import CoreGraphics

struct Message {
    
    // MARK: - Properties
    
    var sender: String?
    var systemMessage: String?
    var textMessage: String?
    var arguments: [CVarArg]
    var location: CGPoint?
    
    // MARK: - Computed properties
    
    var dictionary: NSDictionary {
        let messageDictionary = NSMutableDictionary()
        
        if self.sender != nil {
            messageDictionary[MessageKey.sender.rawValue] = self.sender
        }
        
        if self.systemMessage != nil {
            messageDictionary[MessageKey.systemMessage.rawValue] = self.systemMessage
        }
        
        if self.textMessage != nil {
            messageDictionary[MessageKey.textMessage.rawValue] = self.textMessage
        }
        
        if self.arguments.count > 0 {
            messageDictionary[MessageKey.arguments.rawValue] = self.arguments
        }
        
        if self.location != nil {
            messageDictionary[MessageKey.location.rawValue] = NSCoder.string(for: self.location!)
        }
        
        return messageDictionary
    }
    
    var flashMessage: String? {
        if self.systemMessage != nil {
            return String(format: self.systemMessage!.localized, arguments: self.arguments)
        }
        
        return nil
    }
    
    // MARK: - Initializers
    
    init() {
        self.arguments = []
    }
    
    init(with dictionary: NSDictionary) {
        self.arguments = []
        
        if let value = dictionary[MessageKey.sender.rawValue] as? String {
            self.sender = value
        }
        
        if let value = dictionary[MessageKey.systemMessage.rawValue] as? String {
            self.systemMessage = value
        }
        
        if let value = dictionary[MessageKey.textMessage.rawValue] as? String {
            self.textMessage = value
        }
        
        if let value = dictionary[MessageKey.arguments.rawValue] as? [CVarArg] {
            for argument in value {
                if let number = argument as? NSNumber {
                    self.arguments.append(number.intValue)
                } else {
                    self.arguments.append(argument)
                }
            }
        }
        
        if let value = dictionary[MessageKey.location.rawValue] as? String {
            self.location = NSCoder.cgPoint(for: value)
        }
    }
}

// MARK: - Enum MessageKey

fileprivate enum MessageKey: String {
    case sender = "sender"
    case systemMessage = "systemMessage"
    case textMessage = "textMessage"
    case arguments = "arguments"
    case location = "location"
}
