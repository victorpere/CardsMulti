//
//  CardDeckTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2023-11-19.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import XCTest
@testable import CardsMulti

final class CardDeckTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCardDeckDecode() {
        let cardDeckString = "{\"name\":\"standard\",\"editable\":true,\"cards\":[{\"rank\":2,\"suit\":0},{\"rank\":2,\"suit\":1},{\"rank\":2,\"suit\":2},{\"rank\":2,\"suit\":3},{\"rank\":3,\"suit\":0},{\"rank\":3,\"suit\":1},{\"rank\":3,\"suit\":2},{\"rank\":3,\"suit\":3},{\"rank\":4,\"suit\":0},{\"rank\":4,\"suit\":1},{\"rank\":4,\"suit\":2},{\"rank\":4,\"suit\":3},{\"rank\":5,\"suit\":0},{\"rank\":5,\"suit\":1},{\"rank\":5,\"suit\":2},{\"rank\":5,\"suit\":3},{\"rank\":6,\"suit\":0},{\"rank\":6,\"suit\":1},{\"rank\":6,\"suit\":2},{\"rank\":6,\"suit\":3},{\"rank\":7,\"suit\":0},{\"rank\":7,\"suit\":1},{\"rank\":7,\"suit\":2},{\"rank\":7,\"suit\":3},{\"rank\":8,\"suit\":0},{\"rank\":8,\"suit\":1},{\"rank\":8,\"suit\":2},{\"rank\":8,\"suit\":3},{\"rank\":9,\"suit\":0},{\"rank\":9,\"suit\":1},{\"rank\":9,\"suit\":2},{\"rank\":9,\"suit\":3},{\"rank\":10,\"suit\":0},{\"rank\":10,\"suit\":1},{\"rank\":10,\"suit\":2},{\"rank\":10,\"suit\":3},{\"rank\":11,\"suit\":0},{\"rank\":11,\"suit\":1},{\"rank\":11,\"suit\":2},{\"rank\":11,\"suit\":3},{\"rank\":12,\"suit\":0},{\"rank\":12,\"suit\":1},{\"rank\":12,\"suit\":2},{\"rank\":12,\"suit\":3},{\"rank\":13,\"suit\":0},{\"rank\":13,\"suit\":1},{\"rank\":13,\"suit\":2},{\"rank\":13,\"suit\":3},{\"rank\":1,\"suit\":0},{\"rank\":1,\"suit\":1},{\"rank\":1,\"suit\":2},{\"rank\":1,\"suit\":3}]}"
        
        let data = Data(cardDeckString.utf8)
        let decoder = JSONDecoder()
        let cardDeck = try? decoder.decode(CardDeck.self, from: data)
        
        XCTAssertNotNil(cardDeck)
        XCTAssertEqual("standard", cardDeck?.name)
        XCTAssertEqual(52, cardDeck?.cards.count)
        XCTAssertEqual(true, cardDeck?.editable)
    }
}
