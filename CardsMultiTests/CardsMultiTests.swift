//
//  CardsMultiTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import XCTest
@testable import CardsMulti

class CardsMultiTests: XCTestCase {
    
    var settings = Settings()
    var vc: GameViewController?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.vc = GameViewController()
        self.vc!.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.vc = nil
    }
    
    /*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    */
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */
    
    func testViewControllerLoad() {
        XCTAssertNotNil(self.vc!.view, "View did not load for GameViewController")
    }

    func testskViewLoad() {
        XCTAssertNotNil(self.vc!.skView, "skView did not load for GameViewController")
    }
    
    func testSettings() {
        XCTAssertTrue(settings.minRank <= settings.maxRank, "Settings: min rank is greater than max rank")
    }
    
    func testScene() {
        XCTAssertNotNil(self.vc!.scene, "Scene did not load")
    }
    
    func testDeck() {
        let deck = self.vc!.scene?.allCards

        for card in deck! {
            XCTAssertNotNil(card.card, "Card object is null")
        }
    }
    
    func testReceivedCards() {
        let scene = self.vc!.scene
        //displayCards((scene?.allCards.sorted { $0.zPosition < $1.zPosition })!)
        
        var newDeck = Global.newShuffledDeck(name: "deck", settings: settings)
        
        newDeck.sort { ($0.card?.rank.rawValue)! < ($1.card?.rank.rawValue)! }
        newDeck.sort { ($0.card?.suit.rawValue)! < ($1.card?.suit.rawValue)! }
        
        for (cardIndex, card) in newDeck.enumerated() {
            card.zPosition = CGFloat(cardIndex)
        }
        
        let newDeckDictionaryArray = Global.cardDictionaryArray(with: newDeck, position: .left, width: (scene?.frame.width)!, yOffset: (scene?.dividerLine.position.y)!, moveToFront: true, animate: false)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newDeckDictionaryArray)
            scene?.receivedData(data: jsonData)
            
            let sceneDeck = scene?.allCards.sorted { $0.zPosition < $1.zPosition }
            
            //displayCards(sceneDeck!)
            
            for (cardIndex,card) in newDeck.enumerated() {
                XCTAssertTrue(card.card?.symbol() == sceneDeck?[cardIndex].card?.symbol(), "zPosition doens't match")
                
            }
            
        } catch {
            print("Error serializing json data: \(error)")
        }
        
    }
 
}
