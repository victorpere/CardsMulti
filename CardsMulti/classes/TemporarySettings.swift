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
    
    var game: Int = 0
    
    var minRank: Int = 2
    
    var maxRank: Int = 10
    
    var pips: Bool = true
    
    var jack: Bool = true
    
    var queen: Bool = true
    
    var king: Bool = true
    
    var ace: Bool = true
    
    var cardWidthsPerScreen: Float = 6
    
    var soundOn: Bool = true
    
    var gameTypeOptions: NSDictionary?
    
    init() {
        
    }
    
    init(with settings: Settings) {
        self.displayName = settings.displayName
        self.game = settings.game
        self.minRank = settings.minRank
        self.maxRank = settings.maxRank
        self.pips = settings.pips
        self.jack = settings.jack
        self.queen = settings.queen
        self.king = settings.king
        self.ace = settings.ace
        self.cardWidthsPerScreen = settings.cardWidthsPerScreen
        self.soundOn = settings.soundOn
    }
}
