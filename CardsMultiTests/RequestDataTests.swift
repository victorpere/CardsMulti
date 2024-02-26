//
//  GameDataTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2020-12-05.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import XCTest
@testable import CardsMulti

class RequestDataTests: XCTestCase {
    
    func testDataDictionary() {
        let card = Card(suit: .hearts, rank: .queen)
        let cardNode = CardSpriteNode(card: card, name: "test")
        let cardDictionary = cardNode.cardInfo
        let requestData = RequestData(withType: .game, andDictionary: cardDictionary)
        
        XCTAssertEqual(RequestType.game, requestData.type)
        XCTAssertNotNil(requestData.dataDictionary)
    }
    
    func testDataArray() {
        let settings = TemporarySettings()
        let cards = Global.newShuffledDeck(name: "test", deck: settings.deck)
        let cardDictionaryArray = Global.cardDictionaryArray(with: cards, playerPosition: .top, width: 0, yOffset: 0, moveToFront: false, animate: false, velocity: nil)
        let requestData = RequestData(withType: .game, andArray: cardDictionaryArray)
        
        XCTAssertEqual(RequestType.game, requestData.type)
        XCTAssertNotNil(requestData.dataArray)
    }
    
    func testGameDataFromDictionary() {
        let card = Card(suit: .hearts, rank: .queen)
        let cardNode = CardSpriteNode(card: card, name: "test")
        let cardDictionary = cardNode.cardInfo
        let requestData = RequestData(withType: .game, andDictionary: cardDictionary)

        let data = try? requestData.encodedData()
        XCTAssertNotNil(data)
        
        let receivedRequestData = try? RequestData(withData: data!)
        XCTAssertNotNil(receivedRequestData)
        XCTAssertEqual(RequestType.game, receivedRequestData!.type)
        XCTAssertNotNil(receivedRequestData!.dataDictionary)
    }
    
    func testGameDataFromArray() {
        let settings = TemporarySettings()
        let cards = Global.newShuffledDeck(name: "test", deck: settings.deck)
        let cardDictionaryArray = Global.cardDictionaryArray(with: cards, playerPosition: .top, width: 0, yOffset: 0, moveToFront: false, animate: false, velocity: nil)
        let requestData = RequestData(withType: .game, andArray: cardDictionaryArray)

        let data = try? requestData.encodedData()
        XCTAssertNotNil(data)
        
        let receivedRequestData = try? RequestData(withData: data!)
        XCTAssertNotNil(receivedRequestData)
        XCTAssertEqual(RequestType.game, receivedRequestData!.type)
        XCTAssertNotNil(receivedRequestData!.dataArray)
        
        for arrayElement in receivedRequestData!.dataArray! {
            let cardDictionary = arrayElement as? NSDictionary
            XCTAssertNotNil(cardDictionary)
        }
    }
    
    func testArrayOfRequestData() {
        let card = Card(suit: .hearts, rank: .queen)
        let cardNode = CardSpriteNode(card: card, name: "test")
        let cardDictionary = cardNode.cardInfo
        let requestData1 = RequestData(withType: .game, andDictionary: cardDictionary)
        
        let player = Player(connectionId: "connectionId", displayName: "displayName")
        let requestData2 = RequestData(withType: .requestToSync, andSender: player, andRecipient: player)
        
        let requestDataArray = [requestData1, requestData2]
        let requestData = try? requestDataArray.encodedData()
        
        XCTAssertNotNil(requestData)
    }
}
