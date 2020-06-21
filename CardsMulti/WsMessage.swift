//
//  Message.swift
//  CardsMulti
//
//  Created by Victor on 2020-06-20.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import Foundation

/// A class representing a message sent to or received from AWS
struct WsMessage {
    var status = ""
    var sender = "unknown"
    var text = ""
    var recipients = ""
    var data: Data?
    
    var messageType: WsMessageType {
        switch status {
        case "GamesList":
            return .GamesList
        case "New Connection",
             "Connections update",
             "Created":
            return .ConnectionsUpdate
        case "Message":
            return .TextMessage
        case "Data":
            return .GameData
        default:
            return .Unknown
        }
    }
    
    enum Key : String {
        case status = "status"
        case sender = "sender"
        case text = "message"
        case recipients = "recepients"
    }
        
    init(with data: Data) throws {
        do {
            let messageDictionary = try JSONSerialization.jsonObject(with: data) as! NSDictionary
            
            if let value = messageDictionary[Key.status.rawValue] as? String {
                self.status = value
            }
            if let value = messageDictionary[Key.sender.rawValue] as? String {
                self.sender = value
            }
            if let value = messageDictionary[Key.text.rawValue] as? String {
                self.text = value
            }
            if let value = messageDictionary[Key.recipients.rawValue] as? String {
                self.recipients = value
            }
        } catch {
            throw WsMessageError.FailedToDecodeMessageError
        }
    }
}

enum WsMessageType {
    case GamesList
    case ConnectionsUpdate
    case TextMessage
    case GameData
    case Unknown
}

enum WsMessageError : Error {
    case FailedToDecodeMessageError
}
