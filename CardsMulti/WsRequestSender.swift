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
        
    }
    
    /**
     Find game IDs matching the specified game code
     */
    func findGames(gameCode: String) -> [String] {
        
        return []
    }
    
    /**
     Join an existing game by game ID
     */
    func joinGame(gameId: String) {
        
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
            "action": "onMessage",
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
    
    fileprivate func handleReceivedData(_ data: Data) throws {
        do {
            let wsMessage = try WsMessage(with: data)
            
            switch wsMessage.messageType {
            case .GamesList:
                self.delegate?.didReceiveGamesList()
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
    func didReceiveGamesList()
    func didReceiveConnectionStatus()
    func didReceiveTextMessage(_ message: String, from sender: String)
    func didReceiveGameData(data: Data)
}

// MARK: - WsRequestSenderError enum

enum WsRquestSenderError : Error {
    case FailedToDecodeJson
}
