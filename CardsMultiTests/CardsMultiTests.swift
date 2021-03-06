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
 
}
