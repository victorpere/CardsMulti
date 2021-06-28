//
//  GameConfig.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-20.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class GameConfigs {
    
    // MARK: - Properties
    
    private(set) var configs: [GameType: GameConfig]
    
    // MARK: - Initializers
    
    init(withFile file: String) {
        self.configs = [GameType: GameConfig]()
        
        if let data = NSData(contentsOfFile: file) as Data? {
            try? self.decode(settingsFileContent: data)
        } else {
            
        }
    }
    
    // MARK: - Private methods
    
    private func decode(settingsFileContent: Data) throws {
        do {
            if let settingsArray = try JSONSerialization.jsonObject(with: settingsFileContent, options: []) as? NSArray {
                for element in settingsArray {
                    if let settingsDictionary = element as? NSDictionary {
                        if let value = settingsDictionary[GameConfigKey.gameType.rawValue] as? String, let gameType = try? GameType(withName: value) {
                            var gameConfig = GameConfig(gameType: gameType)
                            
                            if let value = settingsDictionary[GameConfigKey.maxPlayers.rawValue] as? Int {
                                gameConfig.maxPlayers = value
                            }
                            if let value = settingsDictionary[GameConfigKey.canChangeCardSize.rawValue] as? Bool {
                                gameConfig.canChangeCardSize = value
                            }
                            if let value = settingsDictionary[GameConfigKey.canChangeDeck.rawValue] as? Bool {
                                gameConfig.canChangeDeck = value
                            }
                            if let value = settingsDictionary[GameConfigKey.canRotateCards.rawValue] as? Bool {
                                gameConfig.canRotateCards = value
                            }
                            if let value = settingsDictionary[GameConfigKey.options.rawValue] as? NSArray {
                                gameConfig.options = value
                            }
                            if let value = settingsDictionary[GameConfigKey.defaultSettings.rawValue] as? NSDictionary {
                                gameConfig.defaultSettings = self.defaultSettings(fromDictionary: value)
                            }
                            
                            self.configs[gameType] = gameConfig
                        }
                    }
                }
            }
            
        } catch {
            throw GameConfigError.FailedToDeserializeConfigData
        }
    }
    
    private func defaultSettings(fromDictionary settingsDictionary: NSDictionary) -> GameConfigDefaultSettings {
        var defaultSettings = GameConfigDefaultSettings()
        
        if let value = settingsDictionary[GameConfigKey.pipsEnabled.rawValue] as? Bool {
            defaultSettings.pipsEnabled = value
        }
        if let value = settingsDictionary[GameConfigKey.minValue.rawValue] as? Int {
            defaultSettings.minValue = value
        }
        if let value = settingsDictionary[GameConfigKey.maxValue.rawValue] as? Int {
            defaultSettings.maxValue = value
        }
        if let value = settingsDictionary[GameConfigKey.jacksEnabled.rawValue] as? Bool {
            defaultSettings.jacksEnabled = value
        }
        if let value = settingsDictionary[GameConfigKey.queensEnabled.rawValue] as? Bool {
            defaultSettings.queensEnabled = value
        }
        if let value = settingsDictionary[GameConfigKey.kingsEnabled.rawValue] as? Bool {
            defaultSettings.kingsEnabled = value
        }
        if let value = settingsDictionary[GameConfigKey.acesEnabled.rawValue] as? Bool {
            defaultSettings.acesEnabled = value
        }
        if let value = settingsDictionary[GameConfigKey.cardWidthsPerScreen.rawValue] as? Float {
            defaultSettings.cardWidthsPerScreen = value
        }
        
        return defaultSettings
    }
}

// MARK: - Struct GameConfig

struct GameConfig {
    var gameType: GameType
    var maxPlayers: Int = 4
    var canChangeCardSize: Bool = true
    var canChangeDeck: Bool = true
    var canRotateCards: Bool = true
    var options: NSArray?
    
    var defaultSettings = GameConfigDefaultSettings()
}

// MARK: - Struct GameConfigDefaultSettings

struct GameConfigDefaultSettings {
    var pipsEnabled: Bool = true
    var minValue: Int = 2
    var maxValue: Int = 10
    var jacksEnabled: Bool = true
    var queensEnabled: Bool = true
    var kingsEnabled: Bool = true
    var acesEnabled: Bool = true
    var cardWidthsPerScreen: Float = 8
}

// MARK: - Enum GameConfigKey

enum GameConfigKey : String {
    case gameType = "gameType"
    case maxPlayers = "maxPlayers"
    case canChangeCardSize = "canChangeCardSize"
    case canChangeDeck = "canChangeDeck"
    case canRotateCards = "canRotateCards"
    case options = "options"
    case defaultSettings = "defaultSettings"
    case pipsEnabled = "pipsEnabled"
    case minValue = "minValue"
    case maxValue = "maxValue"
    case jacksEnabled = "jacksEnabled"
    case queensEnabled = "queensEnabled"
    case kingsEnabled = "kingsEnabled"
    case acesEnabled = "acesEnabled"
    case cardWidthsPerScreen = "cardWidthsPerScreen"
}

// MARK: - Enum GameConfigError

enum GameConfigError : Error {
    case FailedToDeserializeConfigData
}
