//
//  CurrentSettings.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-27.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class TemporarySettings : Settings {
    var displayName: String = ""
    var cardSet: String?
    var game: Int = 0
    var minRank: Int = 2
    var maxRank: Int = 10
    var pipsEnabled: Bool = true
    var jacksEnabled: Bool = true
    var queensEnabled: Bool = true
    var kingsEnabled: Bool = true
    var acesEnabled: Bool = true
    var cardWidthsPerScreen: Float = 6
    var soundOn: Bool = true
    var customOptions: NSDictionary?
    
    init() { }
    
    init(with settings: Settings) {
        self.displayName = settings.displayName
        self.game = settings.game
        self.minRank = settings.minRank
        self.maxRank = settings.maxRank
        self.pipsEnabled = settings.pipsEnabled
        self.jacksEnabled = settings.jacksEnabled
        self.queensEnabled = settings.queensEnabled
        self.kingsEnabled = settings.kingsEnabled
        self.acesEnabled = settings.acesEnabled
        self.cardWidthsPerScreen = settings.cardWidthsPerScreen
        self.soundOn = settings.soundOn
        self.customOptions = settings.customOptions
    }
}
