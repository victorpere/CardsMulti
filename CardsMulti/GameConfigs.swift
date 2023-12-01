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
    
    let defaultSettings = TemporarySettings()
    
    private(set) var configs: [GameType: GameConfig]
    
    lazy var configArray: [GameConfig] = {
        self.configs.map { $0.value }.sorted { $0.gameType.rawValue < $1.gameType.rawValue }
    }()
    
    // MARK: - Initializers
    
    private init(withFile file: String?) {
        self.configs = [:]
        
        if file != nil, let data = NSData(contentsOfFile: file!) as Data? {
            let decoder = JSONDecoder()
            if let gameConfigs = try? decoder.decode([GameConfig].self, from: data) {
                for gameConfig in gameConfigs {
                    #if DEBUG
                    self.configs[gameConfig.gameType] = gameConfig
                    #else
                    if !(gameConfig.dev ?? false) {
                        self.configs[gameConfig.gameType] = gameConfig
                    }
                    #endif
                }
            }
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
}

// MARK: - Struct GameConfig

struct GameConfig: Codable {
    var gameType: GameType
    var productId: String?
    var maxPlayers: Int = 4
    var canChangeCardSize: Bool = true
    var canChangeDeck: Bool = true
    var canRotateCards: Bool = true
    var defaultSettings = TemporarySettings()
    var buttons: [String] = []
    var dev: Bool?
}
