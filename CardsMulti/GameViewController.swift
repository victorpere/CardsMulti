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
        
        // Configure the view.
        
        let playersIcon = UIImage(named: "icon_players")
        let restartIcon = UIImage(named: "icon_restart")
        let cardsIcon = UIImage(named: "icon_cards")
        
        let barHeight = (playersIcon?.size.height)! + 2 * buttonMargin
        
        backGroundView = UIView(frame: view.frame)
        //backGroundView.backgroundColor = UIColor.black
        backGroundView.backgroundColor = UIColor(patternImage: UIImage(named: UIDevice.current.backgroundFileName)!)
        view.addSubview(backGroundView)
        
        connectionsLabel = UILabel(frame: CGRect(x: 0, y:self.view.frame.height - 30, width: self.view.frame.width, height: 30))
        connectionsLabel.textColor = UIColor.green
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
                self.browsePeers()
            case 3:
                self.lineUpCards()
            default: break
        }
    }
    
    func startGame() {

        connectionsLabel.isHidden = true
        
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
        let peerBrowser = UIAlertController(title: "Select device to connect to:", message: nil, preferredStyle: .actionSheet)
        for peerID in self.connectionService.foundPeers {
            let peerAction = UIAlertAction(title: peerID.displayName, style: .default, handler: { (alert) -> Void in
                self.scene.slave = true
                self.connectionService.invitePeer(peerID) } )
            peerBrowser.addAction(peerAction)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
        peerBrowser.addAction(cancelButton)
        self.present(peerBrowser, animated: true, completion: nil)
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
    
    func connectedDevicesChanged(manager: ConnectionServiceManager, connectedDevices: [MCPeerID]) {
        let connectedDevicesNames = connectedDevices.map({$0.displayName})
        self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
        
        if scene != nil {
            self.scene.connectedDevicesChanged(manager: manager, connectedDevices: connectedDevices)
        }
    }
    
    func receivedData(manager: ConnectionServiceManager, data: Data) {
        if scene != nil {
            self.scene.receivedData(manager: manager, data: data)
        }
    }
    
}

extension GameViewController : GameSceneDelegate {
    
    func sendData(data: Data) {
        self.connectionService.sendData(data: data)
    }
}
