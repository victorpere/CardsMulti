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
    var dataType: WsDataType?
    
    var messageType: WsMessageType {
        return WsMessageType(rawValue: status) ?? WsMessageType.Unknown
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
        case data = "data"
        case dataType = "dataType"
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
            if let value = messageDictionary[Key.data.rawValue] as? String {
                self.data = value.data(using: .utf8)
            }
            if let value = messageDictionary[Key.dataType.rawValue] as? String {
                self.dataType = WsDataType.init(rawValue: value)
            }
        } catch {
            throw WsMessageError.FailedToDecodeMessageError
        }
    }
}

// MARK: - WsMessageType enum

enum WsMessageType : String {
    case GamesList = "GamesList"
    case GameCreated = "Created"
    case GameJoined = "Joined"
    case GameDisconnected = "Disconnected game"
    case NewConnection = "New connection"
    case Disconnection = "Disconnection"
    case ConnectionsUpdate = "Connections update"
    case TextMessage = "Message"
    case GameData = "GameData"
    case PlayerData = "PlayerData"
    case Unknown = "Unknown"
}

// MARK: - WsMessageError enum

enum WsMessageError : Error {
    case FailedToDecodeMessageError
}

// MARK: - ConnectionInfo struct

struct ConnectionInfo {
    var connectionId: String
    var name: String
}
