//
//  WsRequestSender.swift
//  CardsMulti
//
//  Created by Victor on 2020-06-07.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import Foundation
import Starscream

/// A singleton class for sending and receiving game data to/from AWS
class WsRequestSender {
    
    // MARK: - Singleton
    
    static let instance = WsRequestSender()
    
    // MARK: - Public properties
    
    var delegate: WsRequestSenderDelegate?
    
    // MARK: - Private properties
    
    private var webSocket: WebSocket
    
    // MARK: - Initializer
    
    private init() {
        let url = URL(string: Config.awsEndpoint)
        let request = URLRequest(url: url!)
        self.webSocket = WebSocket(request: request)
        self.webSocket.delegate = self
    }
    
    // MARK: - Public methods
    
    /**
     Connct to AWS
     */
    func connect() {
        self.webSocket.connect()
    }
    
    /**
     Disconnect from AWS
     */
    func disconnect() {
        self.webSocket.disconnect()
    }
    
    /**
     Create a new game
     */
    func createGame() {
        let payload: NSDictionary = [
            "action": WsAction.onCreateGame.rawValue,
            "creator": Settings.instance.displayName
        ]
        
        self.sendPayload(payload)
    }
    
    /**
     Find game IDs matching the specified game code
     - parameter gameCode: the game code to find
     */
    func findGames(gameCode: String) {
        let payload: NSDictionary = [
            "action": WsAction.onFindGame.rawValue,
            "gameCode": gameCode
        ]
        
        self.sendPayload(payload)
    }
    
    /**
     Join an existing game by game ID
     - parameter gameID:ID of the game to join
     */
    func joinGame(gameId: String) {
        let payload: NSDictionary = [
            "action": WsAction.onJoinGame.rawValue,
            "playerName": Settings.instance.displayName,
            "gameId": gameId
        ]
        
        self.sendPayload(payload)
    }
    
    /**
     Disconnect from game
     */
    func disconnectFromGame(gameId: String) {
        let payload: NSDictionary = [
            "action": WsAction.onDisconnectGame.rawValue,
            "playerName": Settings.instance.displayName,
            "gameId": gameId
        ]
        
        self.sendPayload(payload)
    }
    
    /**
     Send game or game settings data
     - parameters:
        - data: data to send
        - recepients: recipients in a comma-separated string
     */
    func sendGameData(data: Data, recepients: String) {
        
    }
    
    /**
     Send a text message to the specified recipients
     
     - parameters:
        - sender: the name of the sender
        - text: text of the message
        - recepients: recipients of the message in a comma-separated string
     */
    func sendMessage(sender: String, text: String, recepients: String) {
        let payload: NSDictionary = [
            "action": WsAction.onMessage.rawValue,
            "sender": sender,
            "message": text,
            "recepients": recepients
        ]
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: payload)
            self.webSocket.write(data: payloadData)
        } catch {
            print("Error serializing message into json")
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func sendPayload(_ payload: NSDictionary) {
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: payload)
            if let payloadString = String(data: payloadData, encoding: .utf8) {
                self.webSocket.write(string: payloadString)
            } else {
                print("Error converting data into string")
            }
        } catch {
            print("Error serializing message into json")
        }
    }
    
    fileprivate func handleReceivedData(_ data: Data) throws {
        do {
            let wsMessage = try WsMessage(with: data)
            
            switch wsMessage.messageType {
            case .GameCreated:
                self.delegate?.didCreateGame(connectionId: wsMessage.connectionId, gameId: wsMessage.gameId, gameCode: wsMessage.gameCode)
            case .GamesList:
                self.delegate?.didReceiveGamesList(gameIds: wsMessage.gameIds)
            case .GameJoined:
                self.delegate?.didJoinGame(connectionId: wsMessage.connectionId, gameId: wsMessage.gameId, gameCode: wsMessage.gameCode, creator: wsMessage.creator)
            case .GameDisconnected:
                self.delegate?.didDisconnectFromGame()
            case .ConnectionsUpdate:
                self.delegate?.didReceiveConnectionStatus()
            case .TextMessage:
                self.delegate?.didReceiveTextMessage(wsMessage.text, from: wsMessage.sender)
            case .GameData:
                self.delegate?.didReceiveGameData(data: wsMessage.data ?? Data())
            default:
                break
            }
        } catch {
            throw WsRquestSenderError.FailedToDecodeJson
        }
    }
}

// MARK: - WebSocketDelegate

extension WsRequestSender : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
        self.delegate?.didConnect()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect")
        self.delegate?.didDisconnect()
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage")
        
        let data = Data(text.utf8)
        do {
            try self.handleReceivedData(data)
        } catch {
            self.delegate?.didReceiveTextMessage(text, from: "unknown")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
        
        do {
            try self.handleReceivedData(data)
        } catch {
            print("Error loading json from websocket data")
        }
    }
}

// MARK: - WsRequestSenderDelegate protocol

protocol WsRequestSenderDelegate {
    func didConnect()
    func didDisconnect()
    func didCreateGame(connectionId: String, gameId: String, gameCode: String)
    func didReceiveGamesList(gameIds: [(String, String)])
    func didJoinGame(connectionId: String, gameId: String, gameCode: String, creator: String)
    func didDisconnectFromGame()
    func didReceiveConnectionStatus()
    func didReceiveTextMessage(_ message: String, from sender: String)
    func didReceiveGameData(data: Data)
}

// MARK: - WsRequestSenderError enum

enum WsRquestSenderError : Error {
    case FailedToDecodeJson
}

// MARK: - WsAction enum

enum WsAction : String {
    case onCreateGame = "onCreateGame"
    case onFindGame = "onFindGame"
    case onJoinGame = "onJoinGame"
    case onDisconnectGame = "onDisconnectGame"
    case onMessage = "onMessage"
}
