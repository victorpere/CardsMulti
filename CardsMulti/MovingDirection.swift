//
//  MovingDirection.swift
//  CardsMulti
//
//  Created by Victor on 2018-08-16.
//  Copyright © 2018 Victorius Software Inc. All rights reserved.
//
import CoreGraphics

enum MovingDirection : Int {
    case none, up, down, left, right
    
    init? (transformation: CGPoint) {
        if transformation.x == 0 && transformation.y == 0 {
            self = .none
        } else if transformation.y == 0 || abs(transformation.x) > abs(transformation.y) {
            if transformation.x > 0 {
                self = .right
            } else {
                self = .left
            }
        } else {
            if transformation.y > 0 {
                self = .up
            } else {
                self = .down
            }
        }
    }
    
    func opposite (direction: MovingDirection) -> Bool {
        switch self {
        case .down:
            return direction == .up
        case .up:
            return direction == .down
        case .left:
            return direction == .right
        case .right:
            return direction == .left
        default:
            break
        }
        return false
    }
}

