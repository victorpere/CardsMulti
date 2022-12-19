//
//  GameSceneFactory.swift
//  CardsMulti
//
//  Created by Victor on 2022-08-21.
//  Copyright © 2022 Victorius Software Inc. All rights reserved.
//

import CoreGraphics

class GameSceneFactory {
    static func CreateGameScene(ofType gameType: GameType, ofSize size: CGSize, loadFromSave: Bool) -> GameSceneBase {
        switch gameType {
        case .freePlay:
            return GameScene(size: size, loadFromSave: loadFromSave)
        case .solitare:
            return Solitaire(size: size, loadFromSave: loadFromSave)
        case .freeCell:
            return FreeCell(size: size, loadFromSave: loadFromSave)
        }
    }
}
