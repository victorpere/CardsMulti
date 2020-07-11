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
    var connectionId = ""
    var gameId = ""
    var gameCode = ""
    var gameIds: [(String, String)] = []
    var creator = ""
    
    var messageType: WsMessageType {
        switch status {
        case "GamesList":
            return .GamesList
        case "Created":
            return .GameCreated
        case "Joined":
            return .GameJoined
        case "Disconnected game":
            return .GameDisconnected
        case "New Connection",
             "Connections update":
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
        case connectionId = "connectionId"
        case gameId = "gameId"
        case gameCode = "gameCode"
        case gameIds = "gameIds"
        case creator = "creator"
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
            if let value = messageDictionary[Key.connectionId.rawValue] as? String {
                self.connectionId = value
            }
            if let value = messageDictionary[Key.gameId.rawValue] as? String {
                self.gameId = value
            }
            if let value = messageDictionary[Key.gameCode.rawValue] as? String {
                self.gameCode = value
            }
            if let value = messageDictionary[Key.gameIds.rawValue] as? [NSDictionary] {
                for gameIdDict in value {
                    if let gameId = gameIdDict["gameId"] as? String {
                        if let creator = gameIdDict["creator"] as? String {
                            self.gameIds.append((gameId, creator))
                        }
                    }
                }
            }
            if let value = messageDictionary[Key.creator.rawValue] as? String {
                self.creator = value
            }
        } catch {
            throw WsMessageError.FailedToDecodeMessageError
        }
    }
}

enum WsMessageType {
    case GamesList
    case GameCreated
    case GameJoined
    case GameDisconnected
    case ConnectionsUpdate
    case TextMessage
    case GameData
    case Unknown
}

enum WsMessageError : Error {
    case FailedToDecodeMessageError
}
