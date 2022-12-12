//
//  GameConfig.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-20.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

class GameConfigs {
    
    static let sharedInstance = GameConfigs(withFile: Config.configFilePath)
    
    var defaultSettings = TemporarySettings()
    
    // MARK: - Private properties
    
    private var configs: [GameType: GameConfig]
    
    // MARK: - Initializers
    
    private init(withFile file: String?) {
        self.configs = [GameType: GameConfig]()
        
        if file != nil, let data = NSData(contentsOfFile: file!) as Data? {
            try? self.decode(settingsFileContent: data)
        }
    }
    
    // MARK: - Public methods
    
    /**
     Returns the configuration for the specified game type
     - parameter gameType: game type to get the configuration for
     - returns: configuration for the specified game type
     */
    func gameConfig(for gameType: GameType?) -> GameConfig? {
        if gameType == nil {
            return nil
        }
        
        if let gameConfig = self.configs[gameType!] {
            return gameConfig
        }
        
        return nil
    }
    
    func gameConfig(for productId: String) -> GameConfig? {
        return self.configs.first(where: { $0.value.productId == productId })?.value
    }
    
    // MARK: - Private methods
    
    private func decode(settingsFileContent: Data) throws {
        do {
            if let settingsArray = try JSONSerialization.jsonObject(with: settingsFileContent, options: []) as? NSArray {
                for element in settingsArray {
                    if let settingsDictionary = element as? NSDictionary {
                        if let value = settingsDictionary[GameConfigKey.gameType.rawValue] as? String, let gameType = try? GameType(withName: value) {
                            var gameConfig = GameConfig(gameType: gameType)
                            
                            if let value = settingsDictionary[GameConfigKey.productId.rawValue] as? String {
                                gameConfig.productId = value
                            }
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
                            if let value = settingsDictionary[GameConfigKey.customOptions.rawValue] as? NSDictionary {
                                gameConfig.customOptions = value
                            }
                            if let value = settingsDictionary[GameConfigKey.defaultSettings.rawValue] as? NSDictionary {
                                gameConfig.defaultSettings = self.defaultSettings(fromDictionary: value)
                            }
                            if let value = settingsDictionary[GameConfigKey.buttons.rawValue] as? [String] {
                                gameConfig.buttons = value
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
    
    private func defaultSettings(fromDictionary settingsDictionary: NSDictionary) -> TemporarySettings {
        let defaultSettings = TemporarySettings()
        
        if let value = settingsDictionary[GameConfigKey.pipsEnabled.rawValue] as? Bool {
            defaultSettings.pipsEnabled = value
        }
        if let value = settingsDictionary[GameConfigKey.minValue.rawValue] as? Int {
            defaultSettings.minRank = value
        }
        if let value = settingsDictionary[GameConfigKey.maxValue.rawValue] as? Int {
            defaultSettings.maxRank = value
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
        if let value = settingsDictionary[GameConfigKey.margin.rawValue] as? Float {
            defaultSettings.margin = value
        }
        
        return defaultSettings
    }
}

// MARK: - Struct GameConfig

struct GameConfig {
    var gameType: GameType
    var productId: String?
    var maxPlayers: Int = 4
    var canChangeCardSize: Bool = true
    var canChangeDeck: Bool = true
    var canRotateCards: Bool = true
    var customOptions: NSDictionary?
    
    var defaultSettings = TemporarySettings()
    var buttons: [String] = []
}

// MARK: - Enum GameConfigKey

enum GameConfigKey : String {
    case gameType = "gameType"
    case productId = "productId"
    case maxPlayers = "maxPlayers"
    case canChangeCardSize = "canChangeCardSize"
    case canChangeDeck = "canChangeDeck"
    case canRotateCards = "canRotateCards"
    case customOptions = "customOptions"
    case defaultSettings = "defaultSettings"
    case pipsEnabled = "pipsEnabled"
    case minValue = "minValue"
    case maxValue = "maxValue"
    case jacksEnabled = "jacksEnabled"
    case queensEnabled = "queensEnabled"
    case kingsEnabled = "kingsEnabled"
    case acesEnabled = "acesEnabled"
    case cardWidthsPerScreen = "cardWidthsPerScreen"
    case margin = "margin"
    case buttons = "buttons"
}

// MARK: - Enum GameConfigError

enum GameConfigError : Error {
    case FailedToDeserializeConfigData
}
