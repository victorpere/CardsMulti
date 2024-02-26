//
//  CardNodeTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2023-12-10.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import XCTest

final class CardNodeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCardNodeEncodeDecode() {
        let cardNode1 = CardSpriteNode(card: Card(suit: .hearts, rank: .queen), name: "test")
        let cardNode2 = CardSpriteNode(card: Card(suit: .clubs, rank: .ace), name: "test")
        let cardNodes = [cardNode1, cardNode2]
        
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(cardNodes)
        
        XCTAssertNotNil(encoded)
        
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode([CardSpriteNode].self, from: encoded!)
        
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.count, 2)
    }

}
