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
    
    func testCardDecode() {
        let encodedString = "{\"rank\":2,\"suit\":0}"
        let data = Data(encodedString.utf8)
        let decoder = JSONDecoder()
        let card = try? decoder.decode(Card.self, from: data)
        
        XCTAssertNotNil(card)
        XCTAssertEqual(Suit.spades, card?.suit)
        XCTAssertEqual(Rank.two, card?.rank)
    }
    
    func testCardEncodeDecode() {
        let card = Card(suit: .spades, rank: .two)
        let encoder = JSONEncoder()
        let data = try? encoder.encode(card)
        
        XCTAssertNotNil(data)
        
        let decoder = JSONDecoder()
        let decodedCard = try? decoder.decode(Card.self, from: data!)
        
        XCTAssertEqual(decodedCard, card)
    }
}
