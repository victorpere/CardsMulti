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
    var playerName = ""
    var connections: [ConnectionInfo] = []
    
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
        case "New connection":
            return .NewConnection
        case "Connections update":
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
        case playerName = "playerName"
        case players = "players"
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
                    if let gameId = gameIdDict[Key.gameId.rawValue] as? String {
                        if let creator = gameIdDict[Key.creator.rawValue] as? String {
                            self.gameIds.append((gameId, creator))
                        }
                    }
                }
            }
            if let value = messageDictionary[Key.creator.rawValue] as? String {
                self.creator = value
            }
            if let value = messageDictionary[Key.playerName.rawValue] as? String {
                self.playerName = value
            }
            if let value = messageDictionary[Key.players.rawValue] as? [NSDictionary] {
                for playerDict in value {
                    if let connectionId = playerDict[Key.connectionId.rawValue] as? String {
                        if let playerName = playerDict[Key.playerName.rawValue] as? String {
                            self.connections.append(ConnectionInfo(connectionId: connectionId, name: playerName))
                        }
                    }
                }
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
    case NewConnection
    case ConnectionsUpdate
    case TextMessage
    case GameData
    case Unknown
}

enum WsMessageError : Error {
    case FailedToDecodeMessageError
}

struct ConnectionInfo {
    var connectionId: String
    var name: String
}
