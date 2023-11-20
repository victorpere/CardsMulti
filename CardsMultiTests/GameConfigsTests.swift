//
//  GameConfigsTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2021-06-20.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import XCTest
@testable import CardsMulti

class GameConfigsTests : XCTestCase {
    
    func testGameConfigs() {
        let gameConfigs = GameConfigs.sharedInstance
        let gameConfig = gameConfigs.gameConfig(for: .freePlay)
        XCTAssertNotNil(gameConfig)
    }
    
    func testGameConfigEncode() {
        let gameConfigs = GameConfigs.sharedInstance
        let gameConfig = gameConfigs.gameConfig(for: .solitare)
        let encoder = JSONEncoder()
        let data = try? encoder.encode(gameConfig)
        
        XCTAssertNotNil(data)
        
        let encodedString = String(data: data!, encoding: .utf8)
        XCTAssertNotNil(encodedString)
    }
    
    func testGameConfigsDecode() {
        let gameConfigString = "{ \"gameType\": 1, \"maxPlayers\": 1, \"canChangeCardSize\": false, \"canChangeDeck\": false, \"canRotateCards\": false, \"defaultSettings\": { \"game\": 0, \"deckName\": \"standard\", \"pipsEnabled\": true, \"minValue\": 2, \"maxValue\": 10, \"jacksEnabled\": true, \"queensEnabled\": true, \"kingsEnabled\": true, \"acesEnabled\": true, \"cardWidthsPerScreen\": 8.0, \"margin\": 5.0 }, \"customOptions\" : { \"numberOfCardsToDraw\" : { \"type\": \"Int\", \"defaultValue\": 3 } }, \"buttons\": [ \"autocomplete\" ] }"
        
        let data = Data(gameConfigString.utf8)
        let decoder = JSONDecoder()
        let gameConfig = try? decoder.decode(GameConfig.self, from: data)
        
        XCTAssertNotNil(gameConfig)
        XCTAssertEqual(GameType.solitare, gameConfig?.gameType)
    }
    
}
