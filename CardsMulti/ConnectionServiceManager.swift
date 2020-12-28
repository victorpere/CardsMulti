//
//  ConnectionServiceManager.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

 protocol ConnectionServiceManagerDelegate {
    
    /// will be deprecated
    func receivedData(manager: ConnectionServiceManager, data: Data, type dataType: WsDataType?)
    /// new method
    func didReceive(data: Data)
    func receivedInvitation(from peerID: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    func syncToMe(recipients: [Player]?)
    func newDeviceConnected(peerID: MCPeerID, connectedDevices: [MCPeerID])
    func newPlayerConnected(player: Player, connectedPlayers: [Player?])
    func deviceDisconnected(peerID: MCPeerID, connectedDevices: [MCPeerID])
    func playerDisconnected(player: Player, connectedPlayers: [Player?]) 
    
    func updatePositions(myPosition: Position)
    
    // AWS
    func didConnectAWS()
    func didDisconnectAWS()
    func didGreateGameAWS(gameCode: String)
    func didNotFindGame()
    func didFindGamesAWS(gameIds: [(String, String)])
    func didJoinGameAWS(gameId: String, gameCode: String, creator: String)
    func didDisconnectFromGameAWS()
    func didReceiveTextMessageAWS(_ message: String, from sender: String)
}

class ConnectionServiceManager : NSObject {
    
    private let connectionServiceType = "cards-multi"
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    let myself: Player
    
    /// Websockets game ID
    var gameId: String?
    
    /// Websockets game code
    var gameCode: String?
    
    var hostPeerID: MCPeerID!
    var players: [MCPeerID?] = [nil, nil, nil, nil]
    
    var host: Player?
    var playersAWS: [Player?] = [nil, nil, nil, nil]
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    let serviceBrowser : MCNearbyServiceBrowser
    
    let wsRequestSender: WsRequestSender
    
    var foundPeers = [MCPeerID]()
    
    var delegate: ConnectionServiceManagerDelegate?
    
    // MARK: - Computed properties
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    var connected: Bool {
        return self.session.connectedPeers.count > 0 || self.gameId != nil
    }
    
    var isHost: Bool {
        // OLD WAY
        return self.hostPeerID == self.myPeerId
    }
    
    var isHostAWS: Bool {
        return self.host?.connectionId == self.myself.connectionId
    }
    
    var myPosition: Position {
        // OLD WAY
        for i in 0..<self.players.count {
            if self.players[i] == myPeerId {
                return Position(rawValue: i)!
            }
        }
        return .error
    }
    
    var myPositionAWS: Position {
        for i in 0..<self.playersAWS.count {
            if self.playersAWS[i]?.connectionId == self.myself.connectionId {
                return Position(rawValue: i)!
            }
        }
        return .error
    }
    
    // MARK: - Initializers
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: self.connectionServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: self.connectionServiceType)
        self.myself = Player(peerId: self.myPeerId)
        self.wsRequestSender = WsRequestSender()
        
        super.init()
        
        self.wsRequestSender.delegate = self
        
        self.hostPeerID = self.myPeerId
        
        players[Position.bottom.rawValue] = self.myPeerId
        self.playersAWS[Position.bottom.rawValue] = self.myself
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        
        self.wsRequestSender.disconnect()
    }
    
    // MARK: - Public methods
    
    func startService() {
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
        if !self.wsRequestSender.isConnected {
            self.wsRequestSender.connect()
        }
    }
    
    func stopService() {
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
        self.wsRequestSender.disconnect()
    }
    
    func startAdvertising() {
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func startBrowsing() {
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func stopAdvertising() {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func stopBrowsing() {
        self.serviceBrowser.stopBrowsingForPeers()
        self.foundPeers.removeAll()
    }
    
    func sendData(data: Data, toPeers peers: [MCPeerID]? = nil) {
        if session.connectedPeers.count > 0 {
            do {
                let recipientPeers = peers ?? session.connectedPeers
                try self.session.send(data, toPeers: recipientPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print("%@", "error sending: \(error)")
            }
        }
    }
    
    /**
     Sends game data to all the other AWS players
     */
    func sendDataAWS(data: Data, type dataType: WsDataType, toPlayers players: [Player?]? = nil) {
        if let myConnectionId = self.myself.connectionId {
            let recipientConnectionIds = players == nil ? Array(self.playersAWS.filter({ $0?.connectionId != myConnectionId })).connectionIds : players!.connectionIds
            self.wsRequestSender.sendData(sender: myConnectionId, type: dataType, data: data, recepients: recipientConnectionIds)
        }
    }
    
    func sendPlayerData() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.players)
        self.sendData(data: encodedData)
    }
    
    /**
     Sends player data from the host to the other players connected to AWS
     */
    func sendPlayerDataAWS() {
        if let myConnectionId = self.myself.connectionId {
            let playerDictionaries = self.playersAWS.dictionaries
            let recipients = Array(self.playersAWS.filter({ $0?.connectionId != myConnectionId })).connectionIds
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: playerDictionaries)
                self.wsRequestSender.sendData(sender: myConnectionId, type: .player, data: jsonData, recepients: recipients)
            } catch {
                print("Error serializig player data")
            }
        }
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        self.hostPeerID = peerID
        //self.host = self.myself
        self.serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 15)
    }
    
    func disconnect() {
        self.hostPeerID = self.myPeerId
        self.host = self.myself
        self.session.disconnect()
    }
    

    
    func reassignHost() {
        // OLD WAY
        let allPeers = self.players.filter { $0 != nil }
        self.hostPeerID = allPeers.first!
        
        // NEW WAY
        let allPlayers = self.playersAWS.filter { $0 != nil }
        self.host = allPlayers.first!
    }
    
    // MARK: - AWS methods
    
    /**
     Sends a request to AWS to create a new game
     */
    func createGame() {
        self.wsRequestSender.createGame()
    }
    
    /**
     Sends a request to AWS to find games matching the provided gameCode
     
     - parameter gameCode: the game code to find
     */
    func findGames(gameCode: String) {
        self.wsRequestSender.findGames(gameCode: gameCode)
    }
    
    /**
     Sends a request to AWS to join a game with the provided gameId
     
     - parameter gameId: ID of the game to join
     */
    func joinGame(gameId: String) {
        self.wsRequestSender.joinGame(gameId: gameId)
    }
    
    /**
     Sends a request to AWS to disconnect from the game
     */
    func disconnectFromGame() {
        if (self.gameId != nil) {
            self.wsRequestSender.disconnectFromGame(gameId: self.gameId!)
        }
        self.myself.connectionId = nil
        self.host = self.myself
    }
    
    /**
     Sends a text message to all AWS players in the game
     */
    func sendMessage(text: String) {
        
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension ConnectionServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        //invitationHandler(true, self.session)
        
        self.delegate?.receivedInvitation(from: peerID, invitationHandler: invitationHandler)
    }
    
}

// MARK: - MCNearbyServiceBrowserDelegate

extension ConnectionServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        
        self.foundPeers.append(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
        self.foundPeers.remove(at: foundPeers.firstIndex(of: peerID)!)
    }
    
}

// MARK: - MCSessionDelegate

extension ConnectionServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        
        if state == .connected {
            // a device connected to the game
            
            if session.connectedPeers.count >= 3 {
                self.stopAdvertising()
            }
            
            if self.isHost {
                for i in 0..<self.players.count {
                    if self.players[i] == nil {
                        self.players[i] = peerID
                        break
                    }
                }

                self.sendPlayerData()
                self.delegate?.updatePositions(myPosition: self.myPosition)
                self.delegate?.syncToMe(recipients: [Player(peerId: peerID)])
                self.reassignHost()
            }
            
            //self.delegate?.newDeviceConnected!(peerID: peerID, connectedDevices: session.connectedPeers)
            
        } else if state == .notConnected {
            // a device disconnected from the game
            
            for i in 0..<self.players.count {
                if self.players[i] == peerID { self.players[i] = nil }
            }
            
            if self.hostPeerID == peerID {
                self.reassignHost()
            }
            
            if session.connectedPeers.count < 3 {
                self.startAdvertising()
            }
            
            if session.connectedPeers.count == 0 {
                self.players = [nil, nil, nil, nil]
                self.players[Position.bottom.rawValue] = myPeerId
                self.hostPeerID = self.myPeerId
            }
            
            self.delegate?.deviceDisconnected(peerID: peerID, connectedDevices: session.connectedPeers)
        }
        
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")

        if let receivedPlayers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [MCPeerID?] {
            self.players = receivedPlayers
            self.reassignHost()
            self.delegate?.updatePositions(myPosition: self.myPosition)
        } else {
            self.delegate?.didReceive(data: data)
            //self.delegate?.receivedData(manager: self, data: data, type: .game)
        }
    }
    
    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
}

// MARK: - Extensoin MCSessionState

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
            case .notConnected: return "NotConnected"
            case .connecting: return "Connecting"
            case .connected: return "Connected"
            default: return "Unknown"
        }
    }
    
}

// MARK: - Extension WsRequestSenderDelegate

extension ConnectionServiceManager : WsRequestSenderDelegate {

    func didConnect() {
        self.delegate?.didConnectAWS()
    }
    
    func didDisconnect() {
        self.myself.connectionId = nil
        self.gameId = nil
        self.gameCode = nil
        self.delegate?.didDisconnectAWS()
    }
    
    func didCreateGame(connectionId: String, gameId: String, gameCode: String) {
        self.myself.connectionId = connectionId
        self.gameId = gameId
        self.gameCode = gameCode
        self.myself.position = .bottom
        self.host = self.myself
        
        GameState.instance.gameId = gameId
        
        self.delegate?.didGreateGameAWS(gameCode: gameCode)
    }
    
    func didNotFindGame(gameId: String) {
        self.gameId = nil
        self.gameCode = nil
        self.host = nil
        
        GameState.instance.gameId = nil
        
        self.delegate?.didNotFindGame()
    }
    
    func didReceiveGamesList(gameIds: [(String,String)]) {
        self.delegate?.didFindGamesAWS(gameIds: gameIds)
    }
    
    func didJoinGame(connectionId: String, gameId: String, gameCode: String, creator: String) {
        self.myself.connectionId = connectionId
        self.gameId = gameId
        self.gameCode = gameCode
        self.host = nil
        self.delegate?.didJoinGameAWS(gameId: gameId, gameCode: gameCode, creator: creator)
        
        GameState.instance.gameId = gameId
    }
    
    func didDisconnectFromGame() {
        self.gameId = nil
        self.gameCode = nil
        self.host = nil
        self.delegate?.didDisconnectFromGameAWS()
        
        GameState.instance.gameId = nil
    }
    
    func didReceiveNewConnection(connectionId: String, playerName: String, connections: [ConnectionInfo]) {
        
        if connectionId != self.myself.connectionId {
            let newPlayer = Player(connectionId: connectionId, displayName: playerName)
            
            if self.isHostAWS {
                for i in 0..<self.playersAWS.count {
                    if self.playersAWS[i] == nil {
                        newPlayer.position = Position(rawValue: i) ?? .bottom
                        self.playersAWS[i] = newPlayer
                        break
                    }
                }

                self.sendPlayerDataAWS()
                self.delegate?.updatePositions(myPosition: self.myPositionAWS)
                self.delegate?.syncToMe(recipients: [newPlayer])
                self.reassignHost()
            }
            
            self.delegate?.newPlayerConnected(player: newPlayer, connectedPlayers: self.playersAWS)
        }
    }

    func didReceiveDisconnnection(connectionId: String, playerName: String, connections: [ConnectionInfo]) {
        
        if let disconnectedPlayer = self.playersAWS.first(where: { $0?.connectionId == connectionId }) {
            
            self.delegate?.playerDisconnected(player: disconnectedPlayer!, connectedPlayers: self.playersAWS)
            
            for i in 0..<self.playersAWS.count {
                if self.playersAWS[i]?.connectionId == connectionId {
                    self.playersAWS[i] = nil
                }
            }
        }
    }
    
    func didReceiveConnectionsUpdate(connections: [ConnectionInfo]) {
        
    }
    
    func didReceiveTextMessage(_ message: String, from sender: String) {
        self.delegate?.didReceiveTextMessageAWS(message, from: sender)
    }
    
    func didReceiveGameData(data: Data?, type dataType: WsDataType?) {
        switch dataType {
        case .player:
            self.didReceivePlayerData(data: data)
        default:
            if let receivedData = data {
                self.delegate?.didReceive(data: receivedData)
                
                //self.delegate?.receivedData(manager: self, data: receivedData, type: dataType)
            }
        }
    }
    
    func didReceivePlayerData(data: Data?) {
        if let receivedData = data {
            do {
                if let receivedPlayers = try JSONSerialization.jsonObject(with: receivedData) as? NSArray {
                    
                    var playersAWS: [Player?] = [nil, nil, nil, nil]
                    for element in receivedPlayers {
                        if let receivedPlayer = element as? NSDictionary {
                            let player = try Player(with: receivedPlayer)
                            playersAWS[player.position.rawValue] = player
                        }
                    }
                    
                    self.playersAWS = playersAWS
                    self.reassignHost()
                    self.delegate?.updatePositions(myPosition: self.myPositionAWS)
                }
            } catch {
                print("Error deserializing player data")
            }
        }
    }
}
