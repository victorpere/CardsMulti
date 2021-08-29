//
//  Position.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import CoreGraphics

enum Position : Int, CaseIterable {
    case error = -1
    case bottom = 0, top, left, right
    
    // MARK: - Computed properties
    
    var positionToLeft: Position {
        switch self {
        case .bottom:
            return .left
        case .top:
            return .right
        case .left:
            return .top
        case .right:
            return .bottom
        default:
            break
        }
        return .error
    }
    
    var positionToRight: Position {
        switch self {
        case .bottom:
            return .right
        case .top:
            return .left
        case .left:
            return .bottom
        case .right:
            return .top
        default:
            break
        }
        return .error
    }
    
    var positionAcross: Position {
        switch self {
        case .bottom:
            return .top
        case .top:
            return .bottom
        case .left:
            return .right
        case .right:
            return .left
        default:
            break
        }
        return .error
    }
    
    // MARK: - Public methods
    
    func positionTo(_ direction: Position) -> Position {
        switch direction {
        case .bottom:
            return self
        case .top:
            return self.positionAcross
        case .left:
            return self.positionToLeft
        case .right:
            return self.positionToRight
        default:
            break
        }
        return .error
    }
        
    func transpose(position: CGPoint) -> CGPoint {
        var transposedPosition = position
        switch self {
        case .bottom :
            break
        case .top :
            transposedPosition.x = 1 - position.x
            transposedPosition.y = 1 - position.y
        case .left :
            transposedPosition.x = 1 - position.y
            transposedPosition.y = position.x
        case .right:
            transposedPosition.x = position.y
            transposedPosition.y = 1 - position.x
        default:
            break
        }
        return transposedPosition
    }
    
    func transpose(rotation: CGFloat) -> CGFloat {
        var transposedRotation = rotation
        switch self {
        case .bottom :
            transposedRotation = rotation
        case .top :
            transposedRotation = rotation - CGFloat.pi
        case .left :
            // UNTESTED
            transposedRotation = rotation + CGFloat.pi / 2
        case .right:
            // UNTESTED
            transposedRotation = CGFloat.pi / 2 - rotation - CGFloat.pi / 2
        default:
            break
        }
        return transposedRotation
    }
    
    func transpose(velocity: CGVector) -> CGVector {
        var transposedVelocity = velocity
        switch self {
        case .bottom:
            break
        case .top:
            transposedVelocity = CGVector(dx: -velocity.dx, dy: -velocity.dy)
        case .left:
            transposedVelocity = CGVector(dx: -velocity.dy, dy: velocity.dx)
        case .right:
            transposedVelocity = CGVector(dx: velocity.dy, dy: -velocity.dx)
        default:
            break
        }
        return transposedVelocity
    }
}
