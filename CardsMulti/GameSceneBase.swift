//
//  GameSceneBase.swift
//  CardsMulti
//
//  Created by Victor on 2022-08-21.
//  Copyright © 2022 Victorius Software Inc. All rights reserved.
//

import SpriteKit

class GameSceneBase : SKScene {
    var buttonActions = Dictionary<String, () -> ()>()
    
    func performAction(action actionName: String) {
        if let action = self.buttonActions[actionName] {
            action()
        }
    }
}
