//
//  GameSceneBase.swift
//  CardsMulti
//
//  Created by Victor on 2022-08-21.
//  Copyright © 2022 Victorius Software Inc. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity
import SwiftUI

class GameSceneBase : SKScene {
    /// The delegate of the scene (should be the view controller)
    weak var gameSceneDelegate: GameSceneDelegate?
    
    var buttonActions = Dictionary<String, () -> ()>()
    
    func performAction(action actionName: String) {
        if let action = self.buttonActions[actionName] {
            action()
        }
    }
}

// MARK: - Protocol GameSceneDelegate

protocol GameSceneDelegate: AnyObject {
    
    func sendData(data: Data, type dataType: WsDataType)

    func peers() -> [MCPeerID?]
    
    func presentPopUpMenu(title: String?, withItems items: [PopUpMenuItem]?, at location: CGPoint)
    
    func updatePlayer(numberOfCards: Int, inPosition position: Position)
    
    func presentAlert(title: String?, text: String?, actionTitle: String, action: @escaping (() -> Void), cancelAction: (() -> Void)?)
    
    func flashMessage(_ message: String)
    
    func presentView(_ view: some View)
}
