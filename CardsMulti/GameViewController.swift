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
    
    let connectionService = ConnectionServiceManager()
    
    var connectionsLabel: UILabel!
    var backGroundView: UIView!
    var skView: SKView!
    var scene: GameScene!
    
    var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionService.delegate = self
        
        // Configure the view.
        backGroundView = UIView(frame: view.frame)
        backGroundView.backgroundColor = UIColor.black
        view.addSubview(backGroundView)
        
        
        startButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: 50))
        startButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        startButton.tag = 1
        startButton.setTitle("Start", for: .normal)
        view.addSubview(startButton)
        
        connectionsLabel = UILabel(frame: CGRect(x: 0, y:self.view.frame.height - 30, width: self.view.frame.width, height: 30))
        connectionsLabel.textColor = UIColor.green
        connectionsLabel.text = "Connections: "
        view.addSubview(connectionsLabel)
        
        self.startGame()
    }
    
    func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            self.startGame()
        }
    }
    
    func startGame() {
        startButton.isHidden = true
        connectionsLabel.isHidden = true
        
        //let skView = self.view as! SKView
        skView = SKView(frame: view.frame)
        view.addSubview(skView)
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = true
        
        scene = GameScene(size: skView.frame.size)
        checkForceTouch()
        scene.gameSceneDelegate = self
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.clear
        
        skView.presentScene(scene)
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
