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
    
}
