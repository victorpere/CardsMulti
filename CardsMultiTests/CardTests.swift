//
//  CardTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2023-11-16.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import XCTest
@testable import CardsMulti

class CardTests : XCTestCase {
    func testCardUnicode() {
        let card = Card(suit: .spades, rank: .ace)
        
        XCTAssertEqual("🂡", card.unicode)
    }
}
