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

class GameViewController: UIViewController {
    
    let connectionService = ConnectionServiceManager()
    
    var connectionsLabel: UILabel!
    var backGroundView: UIView!
    
    var testButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionService.delegate = self
        
        // Configure the view.
        backGroundView = UIView(frame: view.frame)
        backGroundView.backgroundColor = UIColor.green
        view.addSubview(backGroundView)
        
        connectionsLabel = UILabel(frame: CGRect(x: 0, y:0, width: 500, height: 100))
        connectionsLabel.text = "Connections: "
        view.addSubview(connectionsLabel)
        
        testButton = UIButton(frame: CGRect(x: 100, y: 400, width: 300, height: 50))
        testButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        testButton.tag = 1
        testButton.setTitle("change colour", for: .normal)
        view.addSubview(testButton)
        
        
        /*
        //let skView = self.view as! SKView
        let skView = SKView(frame: view.frame)
        view.addSubview(skView)
        
        //let handArea = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height / 2)
        //UIColor.green.setFill()
        //UIRectFill(handArea)
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = true
        
        let scene = GameScene(size: skView.frame.size)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.clear
        skView.presentScene(scene)
        */
    }
    
    func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            if backGroundView.backgroundColor == UIColor.green {
                changeColor(UIColor.red)
                connectionService.sendColor(colorName: "red")
            } else {
                changeColor(UIColor.green)
                connectionService.sendColor(colorName: "green")
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

extension GameViewController : ConnectionServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ConnectionServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: ConnectionServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.changeColor(UIColor.red)
            case "green":
                self.changeColor(UIColor.green)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
}
