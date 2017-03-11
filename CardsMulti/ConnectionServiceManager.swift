//
//  ConnectionServiceManager.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc protocol ConnectionServiceManagerDelegate {
    
    @objc optional func receivedData(manager: ConnectionServiceManager, data: Data)
    @objc optional func receivedInvitation(from peerID: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    @objc optional func newDeviceConnected(peerID: MCPeerID, connectedDevices: [MCPeerID])
    @objc optional func deviceDisconnected(peerID: MCPeerID, connectedDevices: [MCPeerID])
    
    @objc optional func updatePositions()
}

class ConnectionServiceManager : NSObject {
    
    private let ConnectionServiceType = "cards-multi"
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    var hostPeerID: MCPeerID!
    var players: [MCPeerID?] = [nil, nil, nil, nil]
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    let serviceBrowser : MCNearbyServiceBrowser
    
    var foundPeers = [MCPeerID]()
    
    var delegate: ConnectionServiceManagerDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ConnectionServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ConnectionServiceType)
        
        super.init()
        
        self.hostPeerID = self.myPeerId
        //self.playerBottom = self.myPeerId
        players[Position.bottom.rawValue] = self.myPeerId
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
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
    }
    
    func sendData(data: Data) {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print("%@", "error sending: \(error)")
            }
        }
    }
    
    func sendPlayerData() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.players)
        self.sendData(data: encodedData)
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        self.hostPeerID = peerID
        self.serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func disconnect() {
        self.hostPeerID = self.myPeerId
        self.session.disconnect()
    }
    
    func isHost() -> Bool {
        return self.hostPeerID == self.myPeerId
    }
    
    func myPosition() -> Position {
        for i in 0..<self.players.count {
            if self.players[i] == myPeerId {
                return Position(rawValue: i)!
            }
        }
        return .error
    }
    
    func reassignHost() {
        let allPeers = self.players.filter { $0 != nil }
        self.hostPeerID = allPeers.first!
    }
}

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
        
        self.delegate?.receivedInvitation!(from: peerID, invitationHandler: invitationHandler)
    }
    
}

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
        
        self.foundPeers.remove(at: foundPeers.index(of: peerID)!)
    }
    
}

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
            
            if self.isHost() {
                for i in 0..<self.players.count {
                    if self.players[i] == nil {
                        self.players[i] = peerID
                        break
                    }
                }

                self.sendPlayerData()
                self.reassignHost()
            }
            
            self.delegate?.newDeviceConnected!(peerID: peerID, connectedDevices: session.connectedPeers)
            
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
            
            self.delegate?.deviceDisconnected!(peerID: peerID, connectedDevices: session.connectedPeers)
        }
        
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")

        if let receivedPlayers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [MCPeerID?] {
            self.players = receivedPlayers
            self.reassignHost()
            self.delegate?.updatePositions!()
        } else {
            self.delegate?.receivedData!(manager: self, data: data)
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
                 at localURL: URL,
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

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
            case .notConnected: return "NotConnected"
            case .connecting: return "Connecting"
            case .connected: return "Connected"
        }
    }
    
}
