//
//  CGVector.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-26.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import CoreGraphics

extension CGVector {
    var direction: MovingDirection {
        get {
            return MovingDirection(transformation: CGPoint(x: self.dx, y: self.dy)) ?? .none
        }
    }
}

extension CGPoint {
    /* return point rotated about the specified centre by the specified angle */
    func rotateAbout(point center: CGPoint, byAngle angle: CGFloat) -> CGPoint {
        let c = cos(angle)
        let s = sin(angle)
        
        let relPoint = CGPoint(x: self.x - center.x, y: self.y - center.y)
        let newRelPoint = CGPoint(x: c * relPoint.x - s * relPoint.y, y: s * relPoint.x + c * relPoint.y)
        
        return CGPoint(x: newRelPoint.x + center.x, y: newRelPoint.y + center.y)
    }
    
    func angleBetween(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let relPointA = CGPoint(x: pointA.x - self.x, y: pointA.y - self.y)
        let relToPoint = CGPoint(x: pointB.x - self.x, y: pointB.y - self.y)
        
        let tanFrom = relPointA.x / relPointA.y
        let tanTo = relToPoint.x / relToPoint.y
        
        let fromAngle = atan(tanFrom)
        let toAngle = atan(tanTo)
        
        return toAngle - fromAngle
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
}
