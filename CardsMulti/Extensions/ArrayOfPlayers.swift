//
//  ArrayOfPlayers.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

extension Array where Element:Player {
    mutating func remove(playerNumber: Int) -> Int {
        for (playerIndex, player) in self.enumerated() {
            if player.playerNumber == playerNumber {
                self.remove(at: playerIndex)
                return playerIndex
            }
        }
        return -1
    }
}
