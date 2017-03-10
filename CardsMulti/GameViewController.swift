//
//  GameViewController.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    let buttonMargin: CGFloat = 8.0
    
    let connectionService = ConnectionServiceManager()
    //var host: MCPeerID!
    
    var playerBottom: MCPeerID?
    var playerTop: MCPeerID?
    var playerLeft: MCPeerID?
    var playerRight: MCPeerID?
    
    var connectionsLabel: UILabel!
    var backGroundView: UIView!
    var skView: SKView!
    var scene: GameScene!
    
    
    var restartButton: UIButton!
    var numberOfPlayersButton: UIButton!
    var lineUpCardsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionService.delegate = self
        //host = connectionService.myPeerId
        playerBottom = connectionService.myPeerId
        
        // Configure the view.
        
        let playersIcon = UIImage(named: "icon_players")
        let restartIcon = UIImage(named: "icon_restart")
        let cardsIcon = UIImage(named: "icon_cards")
        
        let barHeight = (playersIcon?.size.height)! + 2 * buttonMargin
        
        backGroundView = UIView(frame: view.frame)
        //backGroundView.backgroundColor = UIColor.black
        backGroundView.backgroundColor = UIColor(patternImage: UIImage(named: UIDevice.current.backgroundFileName)!)
        view.addSubview(backGroundView)
        
        connectionsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 15))
        connectionsLabel.textColor = UIColor.green
        connectionsLabel.font = UIFont(name: "Helvetica", size: 15)
        connectionsLabel.text = "Connections: "
        view.addSubview(connectionsLabel)

        
        lineUpCardsButton = UIButton(frame: CGRect(x: buttonMargin, y: view.frame.height - buttonMargin - (cardsIcon?.size.height)!, width: (cardsIcon?.size.height)!, height: (cardsIcon?.size.height)!))
        lineUpCardsButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        lineUpCardsButton.tag = 3
        lineUpCardsButton.setImage(cardsIcon, for: .normal)
        view.addSubview(lineUpCardsButton)
        
        numberOfPlayersButton = UIButton(frame: CGRect(x: view.frame.midX - (playersIcon!.size.width / 2), y: view.frame.height - buttonMargin - (restartIcon?.size.height)!, width: (playersIcon?.size.width)!, height: (playersIcon?.size.height)!))
        numberOfPlayersButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        numberOfPlayersButton.tag = 2
        numberOfPlayersButton.setImage(playersIcon, for: .normal)
        view.addSubview(numberOfPlayersButton)
        
        restartButton = UIButton(frame: CGRect(x: view.frame.width - buttonMargin - (restartIcon?.size.width)!, y: view.frame.height - buttonMargin - (restartIcon?.size.height)!, width: (restartIcon?.size.height)!, height: (restartIcon?.size.height)!))
        restartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        restartButton.tag = 1
        restartButton.setImage(restartIcon, for: .normal)
        view.addSubview(restartButton)
        
        //let skView = self.view as! SKView
        let sceneFrame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height - barHeight)
        skView = SKView(frame: sceneFrame)
        //skView = SKView(frame: view.frame)
        view.addSubview(skView)
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = true
        
        self.startGame()
    }
    
    func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        switch btnsendtag.tag {
            case 1:
                self.resetGame()
            case 2:
                if self.connectionService.session.connectedPeers.count > 0 {
                    self.disconnectFromPeer()
                } else {
                    self.browsePeers()
                }
            case 3:
                self.lineUpCards()
            default: break
        }
    }
    
    func startGame() {

        //connectionsLabel.isHidden = true
        
        scene = GameScene(size: skView.frame.size)
        checkForceTouch()
        scene.gameSceneDelegate = self
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.clear
        
        skView.presentScene(scene)
    }
    
    func resetGame() {
        scene.resetCards(sync: true)
    }
    
    func lineUpCards() {
        scene.resetHand()
    }
    
    func browsePeers() {
        
        let peerBrowser = UIAlertController(title: "Select device to join:", message: nil, preferredStyle: .actionSheet)
        for peerID in self.connectionService.foundPeers {
            let peerAction = UIAlertAction(title: peerID.displayName, style: .default, handler: { (alert) -> Void in
                self.connectionService.invitePeer(peerID)
            } )
            peerBrowser.addAction(peerAction)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
        peerBrowser.addAction(cancelButton)
        self.present(peerBrowser, animated: true, completion: nil)
    }
    
    func disconnectFromPeer() {
        let connectionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let disconnectButton = UIAlertAction(title: "Disconnect from the game", style: .default, handler: { (alert) -> Void in
            self.connectionService.disconnect()
        } )
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
        
        connectionAlert.addAction(disconnectButton)
        connectionAlert.addAction(cancelButton)
        self.present(connectionAlert, animated: true, completion: nil)
    }
    
    func checkForceTouch() {
        if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            print("force touch available")
            if self.scene != nil {
                self.scene.forceTouch = true
            }
        }
    }
    
    func changeColor(_ color: UIColor) {
        backGroundView.backgroundColor = color
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}


/*
 Trait collection change
 */
extension GameViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.checkForceTouch()
    }
}


extension GameViewController : ConnectionServiceManagerDelegate {
    
    func newDeviceConnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        DispatchQueue.main.async {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
        }
        
        if self.connectionService.isHost() {
            self.scene.syncToMe()
        }
    }
    
    func deviceDisconnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        DispatchQueue.main.async {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
        }
    }
    
    func receivedData(manager: ConnectionServiceManager, data: Data) {
        self.scene.receivedData(manager: manager, data: data)
    }
    
    func receivedInvitation(from peerID: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            let invitationAlert = UIAlertController(title: "\(peerID.displayName) wants to connect to the game", message: nil, preferredStyle: .alert)
            let allow = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
                    invitationHandler(true, self.connectionService.session)
                } )
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
            
            invitationAlert.addAction(allow)
            invitationAlert.addAction(cancelButton)
            self.present(invitationAlert, animated: true, completion: nil)
        }
    }
    
}

extension GameViewController : GameSceneDelegate {
    
    func sendData(data: Data) {
        self.connectionService.sendData(data: data)
    }
}

/*
extension GameViewController : MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
 */
