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
        //let file = Bundle.main.path(forResource: "gameConfigs1.json", ofType: nil)!
        
        //let bundle = Bundle(for: type(of: self))
        //let file = bundle.path(forResource: "gameConfigs1", ofType: "json")!
        
        let gameConfigs = GameConfigs.sharedInstance
        let gameConfig = gameConfigs.gameConfig(for: .freePlay)
        XCTAssertNotNil(gameConfig)
    }
    
}
