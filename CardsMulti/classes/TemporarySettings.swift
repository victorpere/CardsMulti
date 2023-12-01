//
//  CurrentSettings.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-27.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class TemporarySettings : Settings, GameSettings, ObservableObject, Codable {
    @Published var displayName: String = ""
    var cardSet: String?
    @Published var game: Int = 0
    @Published var cardWidthsPerScreen: Float = 6
    var margin: Float = 5
    @Published var soundOn: Bool = true
    var customOptions: NSDictionary?
    @Published var deck: CardDeck = CardDeck.empty
    
    var presetCardSize: String? {
        if let presetCardWidth = Config.presetCardWidthsPerScreen.first(where: { $0.value == self.cardWidthsPerScreen}) {
            return presetCardWidth.key
        }
        
        return nil
    }
    
    // MARK: - Initializers
    
    init() { }
    
    init(with settings: Settings) {
        self.displayName = settings.displayName
        self.game = settings.game
        self.cardWidthsPerScreen = settings.cardWidthsPerScreen
        self.soundOn = settings.soundOn
        self.margin = settings.margin
        self.customOptions = settings.customOptions
        self.deck = settings.deck
    }
    
    // MARK: - Encode / decode
    
    private enum CodingKeys: String, CodingKey {
        case displayName
        case game
        case cardWidthsPerScreen
        case soundOn
        case margin
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.cardWidthsPerScreen = try values.decode(Float.self, forKey: .cardWidthsPerScreen)
        self.margin = try values.decode(Float.self, forKey: .margin)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.cardWidthsPerScreen, forKey: .cardWidthsPerScreen)
        try container.encode(self.margin, forKey: .margin)
    }

    // MARK: - Public methods
    
    func sync(to gameSettings: GameSettings) {
        self.cardWidthsPerScreen = gameSettings.cardWidthsPerScreen
        self.margin = gameSettings.margin
        self.customOptions = gameSettings.customOptions
        self.deck = gameSettings.deck
    }
    
    func syncUI(to gameSettings: GameSettings) {
        self.cardWidthsPerScreen = gameSettings.cardWidthsPerScreen
        self.margin = gameSettings.margin
    }
    
    func store() {
        StoredSettings.instance.displayName = self.displayName
        StoredSettings.instance.game = self.game
        StoredSettings.instance.cardWidthsPerScreen = self.cardWidthsPerScreen
        StoredSettings.instance.margin = self.margin
        StoredSettings.instance.customOptions = self.customOptions
        StoredSettings.instance.deck = self.deck
        
        StoredSettings.instance.soundOn = self.soundOn
    }
}

