//
//  WsRequestSender.swift
//  CardsMulti
//
//  Created by Victor on 2020-06-07.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import Foundation
import Starscream

/// A class for sending and receiving game data to/from AWS
class WsRequestSender {
    
    // MARK: - Public properties
    
    var delegate: WsRequestSenderDelegate?
    
    var isConnected: Bool {
        return self.webSocket.isConnected
    }
    
    // MARK: - Private properties
    
    private var webSocket: WebSocket
    
    /// The parameter to be used with waitingFunc
    private var waitingParam: String?
    
    /// This function will execute when connection is established
    private var waitingFunc: ((String) -> Void)?
    
    // MARK: - Initializer
    
    init() {
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
            "creator": StoredSettings.instance.displayName
        ]
        
        self.sendPayload(payload)
    }
    
    /**
     Find game IDs matching the specified game code
     - parameter gameCode: the game code to find
     */
    func findGames(withGameCode gameCode: String) {
        if (!self.isConnected) {
            self.waitingParam = gameCode
            self.waitingFunc = self.findGames(withGameCode:)
            self.connect()
            return
        }
        
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
            "playerName": StoredSettings.instance.displayName,
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
            "playerName": StoredSettings.instance.displayName,
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
    func sendData(sender: String, type: WsDataType, data: Data, recepients: String) {
        if let dataString = String(data: data, encoding: .utf8) {
            let payload: NSDictionary = [
                "action": WsAction.onData.rawValue,
                "sender": sender,
                "type": type.rawValue,
                "data": dataString,
                "recepients": recepients
            ]
        
            self.sendPayload(payload)
        }
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
            print("Received \(wsMessage.messageType.rawValue) at \(Date())")
            
            switch wsMessage.messageType {
            case .GameCreated:
                self.delegate?.didCreateGame(connectionId: wsMessage.connectionId, gameId: wsMessage.gameId, gameCode: wsMessage.gameCode)
            case .GamesList:
                self.delegate?.didReceiveGamesList(gameIds: wsMessage.gameIds)
            case .GameJoined:
                self.delegate?.didJoinGame(connectionId: wsMessage.connectionId, gameId: wsMessage.gameId, gameCode: wsMessage.gameCode, creator: wsMessage.creator)
            case .GameNotFound:
                self.delegate?.didNotFindGame(gameId: wsMessage.gameId)
            case .GameDisconnected:
                self.delegate?.didDisconnectFromGame()
            case .NewConnection:
                self.delegate?.didReceiveNewConnection(connectionId: wsMessage.connectionId, playerName: wsMessage.playerName, connections: wsMessage.connections)
            case .Disconnection:
                self.delegate?.didReceiveDisconnnection(connectionId: wsMessage.connectionId, playerName: wsMessage.playerName, connections: wsMessage.connections)
            case .ConnectionsUpdate:
                self.delegate?.didReceiveConnectionsUpdate(connections: wsMessage.connections)
            case .TextMessage:
                self.delegate?.didReceiveTextMessage(wsMessage.text, from: wsMessage.sender)
            case .GameData:
                self.delegate?.didReceiveGameData(data: wsMessage.data, type: wsMessage.dataType)
            default:
                break
            }
        } catch {
            throw WsRequestSenderError.FailedToDecodeJson
        }
    }
}

// MARK: - WebSocketDelegate

extension WsRequestSender : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")        
        self.delegate?.didConnect()
        
        if let param = self.waitingParam, let function = self.waitingFunc {
            function(param)
            
            self.waitingParam = nil
            self.waitingFunc = nil
        }
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
    func didNotFindGame(gameId: String)
    func didDisconnectFromGame()
    func didReceiveNewConnection(connectionId: String, playerName: String, connections: [ConnectionInfo])
    func didReceiveDisconnnection(connectionId: String, playerName: String, connections: [ConnectionInfo])
    func didReceiveConnectionsUpdate(connections: [ConnectionInfo])
    func didReceiveTextMessage(_ message: String, from sender: String)
    func didReceiveGameData(data: Data?, type dataType: WsDataType?)
    func didReceivePlayerData(data: Data?)
}

// MARK: - WsRequestSenderError enum

enum WsRequestSenderError : Error {
    case FailedToDecodeJson
}

// MARK: - WsAction enum

enum WsAction : String {
    case onCreateGame = "onCreateGame"
    case onFindGame = "onFindGame"
    case onJoinGame = "onJoinGame"
    case onDisconnectGame = "onDisconnectGame"
    case onData = "onData"
    case onMessage = "onMessage"
}

// MARK: - WsDataType enum

enum WsDataType : String {
    case player = "PlayerData"
    case game = "GameData"
    case settings = "SettingsData"
}
