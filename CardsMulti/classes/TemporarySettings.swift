//
//  CurrentSettings.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-27.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class TemporarySettings : Settings, GameSettings, ObservableObject {
    @Published var displayName: String = ""
    var cardSet: String?
    @Published var game: Int = 0
    var minRank: Int = 2
    var maxRank: Int = 10
    var pipsEnabled: Bool = true
    var jacksEnabled: Bool = true
    var queensEnabled: Bool = true
    var kingsEnabled: Bool = true
    var acesEnabled: Bool = true
    var cardWidthsPerScreen: Float = 6
    var margin: Float = 5
    var soundOn: Bool = true
    var customOptions: NSDictionary?
    
    var presetCardSize: String? {
        if let presetCardWidth = Config.presetCardWidthsPerScreen.first(where: { $0.value == self.cardWidthsPerScreen}) {
            return presetCardWidth.key
        }
        
        return nil
    }
    
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
        self.margin = settings.margin
        self.customOptions = settings.customOptions
    }
    
    func sync(to gameSettings: GameSettings) {
        self.minRank = gameSettings.minRank
        self.maxRank = gameSettings.maxRank
        self.pipsEnabled = gameSettings.pipsEnabled
        self.jacksEnabled = gameSettings.jacksEnabled
        self.queensEnabled = gameSettings.queensEnabled
        self.kingsEnabled = gameSettings.kingsEnabled
        self.acesEnabled = gameSettings.acesEnabled
        self.cardWidthsPerScreen = gameSettings.cardWidthsPerScreen
        self.margin = gameSettings.margin
        self.customOptions = gameSettings.customOptions
    }
    
    func syncUI(to gameSettings: GameSettings) {
        self.cardWidthsPerScreen = gameSettings.cardWidthsPerScreen
        self.margin = gameSettings.margin
    }
    
    func store() {
        StoredSettings.instance.displayName = self.displayName
        StoredSettings.instance.game = self.game
        
        StoredSettings.instance.minRank = self.minRank
        StoredSettings.instance.maxRank = self.maxRank
        StoredSettings.instance.pipsEnabled = self.pipsEnabled
        StoredSettings.instance.jacksEnabled = self.jacksEnabled
        StoredSettings.instance.queensEnabled = self.queensEnabled
        StoredSettings.instance.kingsEnabled = self.kingsEnabled
        StoredSettings.instance.acesEnabled = self.acesEnabled
        StoredSettings.instance.cardWidthsPerScreen = self.cardWidthsPerScreen
        StoredSettings.instance.margin = self.margin
        StoredSettings.instance.customOptions = self.customOptions
        
        StoredSettings.instance.soundOn = self.soundOn
    }
}
