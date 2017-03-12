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
    let numberOfButtons: CGFloat = 5
    
    let connectionService = ConnectionServiceManager()
    //var host: MCPeerID!
    
    
    var connectionsLabel: UILabel!
    var positionLabel: UILabel!
    
    var backGroundView: UIView!
    var skView: SKView!
    var scene: GameScene!
    
    
    var restartButton: BottomButton!
    var settingsButton: BottomButton!
    var numberOfPlayersButton: BottomButton!
    var lineUpCardsButton: BottomButton!
    var sortCardsButton: BottomButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionService.delegate = self
        
        // Configure the view.
        
        let playersIcon = UIImage(named: "icon_players")
        
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

        positionLabel = UILabel(frame: CGRect(x: 0, y: 15, width: self.view.frame.width, height: 120))
        positionLabel.textColor = UIColor.green
        positionLabel.font = UIFont(name: "Helvetica", size: 10)
        positionLabel.numberOfLines = 0
        positionLabel.text = "\(self.connectionService.myPeerId)\n\(self.connectionService.hostPeerID)\n\(self.connectionService.myPosition())\n"
        for player in self.connectionService.players {
            positionLabel.text?.append("\(player)\n")
        }
        view.addSubview(positionLabel)
        positionLabel.isHidden = true
        
        lineUpCardsButton = BottomButton(withIconNamed: "icon_cards", viewFrame: self.view.frame, buttonNumber: 0, numberOfButtons: numberOfButtons, tag: 3)
        lineUpCardsButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(lineUpCardsButton)
        
        sortCardsButton = BottomButton(withIconNamed: "icon_cards_sort", viewFrame: self.view.frame, buttonNumber: 1, numberOfButtons: numberOfButtons, tag: 5)
        sortCardsButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(sortCardsButton)
        
        settingsButton = BottomButton(withIconNamed: "icon_settings", viewFrame: self.view.frame, buttonNumber: 2, numberOfButtons: numberOfButtons, tag: 4)
        settingsButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        numberOfPlayersButton = BottomButton(withIconNamed: "icon_players", viewFrame: self.view.frame, buttonNumber: 3, numberOfButtons: numberOfButtons, tag: 2)
        numberOfPlayersButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(numberOfPlayersButton)
        
        restartButton = BottomButton(withIconNamed: "icon_restart", viewFrame: self.view.frame, buttonNumber: 4, numberOfButtons: numberOfButtons, tag: 1)
        restartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
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
        case 4:
            self.openSettings()
        case 5:
            self.sortCards()
            
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
        scene.resetHand(sort: false)
    }
    
    func sortCards() {
        scene.resetHand(sort: true)
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
        
        let presentationController = peerBrowser.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = self.numberOfPlayersButton
        presentationController?.sourceRect = self.numberOfPlayersButton.bounds
        
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
    
    func openSettings() {
        let settingsViewController = SettingsViewController(nibName: nil, bundle: nil)
        settingsViewController.modalPresentationStyle = .popover
        settingsViewController.delegate = self
        
        let presentationController = settingsViewController.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = self.settingsButton
        presentationController?.sourceRect = self.settingsButton.bounds
        
        self.present(settingsViewController, animated: true, completion: nil)
    }
    
    func checkForceTouch() {
        if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            print("force touch available")
            if self.scene != nil {
                self.scene.forceTouch = true
            }
        }
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

    func updateLabels() {
        DispatchQueue.main.async {
            self.positionLabel.text = "\(self.connectionService.myPeerId)\n\(self.connectionService.hostPeerID)\n\(self.connectionService.myPosition())\n"
            for player in self.connectionService.players {
                self.positionLabel.text?.append("\(player)\n")
            }
        }
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
            self.updateLabels()
        }
        
        self.scene.playerPosition = self.connectionService.myPosition()
        
        if self.connectionService.isHost() {
            self.scene.syncToMe()
        }
        self.scene.playerPosition = self.connectionService.myPosition()
    }
    
    func deviceDisconnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        DispatchQueue.main.async {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
            self.updateLabels()
        }
        self.scene.playerPosition = self.connectionService.myPosition()
    }
    
    func updatePositions() {
        self.updateLabels()
        self.scene.playerPosition = self.connectionService.myPosition()
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

extension GameViewController : SettingsViewControllerDelegate {
    
    func settingsChanged() {
        self.scene.resetGame(sync: true)
    }
}
