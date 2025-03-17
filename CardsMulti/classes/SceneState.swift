//
//  SceneState.swift
//  CardsMulti
//
//  Created by Victor on 2025-01-18.
//  Copyright © 2025 Victorius Software Inc. All rights reserved.
//

import Foundation

struct SceneState : Codable {
    var cardNodes: [CardSpriteNode]
    var scores: [Score]
}
