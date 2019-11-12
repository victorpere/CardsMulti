//
//  Math.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import CoreGraphics

class Math {
    static func hypotenuse(from vector: CGVector) -> Double {
        return Double(hypot(vector.dx, vector.dy))
    }

    static func acceleration2d(linearAcceleration: Double, speed: CGVector) -> CGVector {
        let angle = atan(Double(speed.dx / speed.dy))
        return CGVector(dx: abs(linearAcceleration * sin(angle)) * copysign(1.0, Double(speed.dx)), dy: abs(linearAcceleration * cos(angle)) * copysign(1.0, Double(speed.dy)))
    }

    static func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * Double.pi)
    }
    
    /**
     Returns distace between two points
     
     - parameters:
        - pointA: first point
        - pointB: second point
     */
    static func distance(between pointA: CGPoint, and pointB: CGPoint) -> CGFloat {
        let dx = pointB.x - pointA.x
        let dy = pointB.y - pointA.y
        return abs(hypot(dx, dy))
    }
}
