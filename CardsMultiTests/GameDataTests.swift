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
        let gameData = RequestData(withType: .game, andDictionary: cardDictionary)
        
        XCTAssertEqual(RequestType.game, gameData.type)
        XCTAssertNotNil(gameData.dataDictionary)
    }
    
    func testDataArray() {
        let cards = Global.newShuffledDeck(name: "test", settings: Settings.instance)
        let cardDictionaryArray = Global.cardDictionaryArray(with: cards, playerPosition: .top, width: 0, yOffset: 0, moveToFront: false, animate: false)
        let gameData = RequestData(withType: .game, andArray: cardDictionaryArray)
        
        XCTAssertEqual(RequestType.game, gameData.type)
        XCTAssertNotNil(gameData.dataArray)
    }
    
    func testGameDataFromDictionary() {
        let card = Card(suit: .hearts, rank: .queen)
        let cardNode = CardSpriteNode(card: card, name: "test")
        let cardDictionary = cardNode.cardInfo
        let requestData = RequestData(withType: .game, andDictionary: cardDictionary)
        do {
            let data = try requestData.encodedData()
            XCTAssertNotNil(data)
            
            let receivedRequestData = try RequestData(withData: data!)
            XCTAssertEqual(RequestType.game, receivedRequestData.type)
            XCTAssertNotNil(receivedRequestData.dataDictionary)
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func testGameDataFromArray() {
        let cards = Global.newShuffledDeck(name: "test", settings: Settings.instance)
        let cardDictionaryArray = Global.cardDictionaryArray(with: cards, playerPosition: .top, width: 0, yOffset: 0, moveToFront: false, animate: false)
        let requestData = RequestData(withType: .game, andArray: cardDictionaryArray)
        
        do {
            let data = try requestData.encodedData()
            XCTAssertNotNil(data)
            
            let receivedRequestData = try RequestData(withData: data!)
            XCTAssertEqual(RequestType.game, receivedRequestData.type)
            XCTAssertNotNil(receivedRequestData.dataArray)
            
            for arrayElement in receivedRequestData.dataArray! {
                let cardDictionary = arrayElement as? NSDictionary
                XCTAssertNotNil(cardDictionary)
            }
        } catch {
            XCTAssertTrue(false)
        }
    }
}
