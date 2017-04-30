//
//  Math.swift
//  durak1
//
//  Created by Victor on 2017-01-29.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import GameplayKit

class Math {
    static func hypotenuse(from vector: CGVector) -> Double {
        return Double(hypot(vector.dx, vector.dy))
    }

    static func acceleration2d(linearAcceleration: Double, speed: CGVector) -> CGVector {
        let angle = atan(Double(speed.dx / speed.dy))
        return CGVector(dx: abs(linearAcceleration * sin(angle)) * copysign(1.0, Double(speed.dx)), dy: abs(linearAcceleration * cos(angle)) * copysign(1.0, Double(speed.dy)))
    }

    static func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * M_PI)
    }
}
