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
    
    func testCardDeck() {
        let deck = CardDeck.standard
        let jsonEncoder = JSONEncoder()
        
        let jsonData = try? jsonEncoder.encode(deck)
        XCTAssertNotNil(jsonData)
        
        let jsonString = String(data: jsonData!, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        
        print(jsonString!)
        
        XCTAssertEqual("{\"cards\":[{\"rank\":2,\"suit\":0},{\"rank\":2,\"suit\":1},{\"rank\":2,\"suit\":2},{\"rank\":2,\"suit\":3},{\"rank\":3,\"suit\":0},{\"rank\":3,\"suit\":1},{\"rank\":3,\"suit\":2},{\"rank\":3,\"suit\":3},{\"rank\":4,\"suit\":0},{\"rank\":4,\"suit\":1},{\"rank\":4,\"suit\":2},{\"rank\":4,\"suit\":3},{\"rank\":5,\"suit\":0},{\"rank\":5,\"suit\":1},{\"rank\":5,\"suit\":2},{\"rank\":5,\"suit\":3},{\"rank\":6,\"suit\":0},{\"rank\":6,\"suit\":1},{\"rank\":6,\"suit\":2},{\"rank\":6,\"suit\":3},{\"rank\":7,\"suit\":0},{\"rank\":7,\"suit\":1},{\"rank\":7,\"suit\":2},{\"rank\":7,\"suit\":3},{\"rank\":8,\"suit\":0},{\"rank\":8,\"suit\":1},{\"rank\":8,\"suit\":2},{\"rank\":8,\"suit\":3},{\"rank\":9,\"suit\":0},{\"rank\":9,\"suit\":1},{\"rank\":9,\"suit\":2},{\"rank\":9,\"suit\":3},{\"rank\":10,\"suit\":0},{\"rank\":10,\"suit\":1},{\"rank\":10,\"suit\":2},{\"rank\":10,\"suit\":3},{\"rank\":11,\"suit\":0},{\"rank\":11,\"suit\":1},{\"rank\":11,\"suit\":2},{\"rank\":11,\"suit\":3},{\"rank\":12,\"suit\":0},{\"rank\":12,\"suit\":1},{\"rank\":12,\"suit\":2},{\"rank\":12,\"suit\":3},{\"rank\":13,\"suit\":0},{\"rank\":13,\"suit\":1},{\"rank\":13,\"suit\":2},{\"rank\":13,\"suit\":3},{\"rank\":14,\"suit\":0},{\"rank\":14,\"suit\":1},{\"rank\":14,\"suit\":2},{\"rank\":14,\"suit\":3}]}", jsonString)
    }
}
