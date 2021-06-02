//
//  MathTests.swift
//  CardsMultiTests
//
//  Created by Victor on 2021-01-16.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import XCTest
@testable import CardsMulti

class MathTests: XCTestCase {
    
    func testAngleOfLineBetweenPoints() {
        let pointA = CGPoint(x: 0, y: 0)
        let pointB = CGPoint(x: 1, y: 1)
        let angle = Math.angleOfLine(between: pointA, and: pointB)
        let expectedAngle = Math.degToRad(degree: 45)
        XCTAssertEqual(angle, expectedAngle)
    }
    
}
