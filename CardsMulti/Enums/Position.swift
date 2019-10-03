//
//  Position.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

enum Position : Int {
    case error = -1
    case bottom = 0, top, left, right
    
    func positionTo(_ direction: Position) -> Position {
        switch direction {
        case .bottom:
            return self
        case .top:
            return self.positionAcross()
        case .left:
            return self.positionToLeft()
        case .right:
            return self.positionToRight()
        default:
            break
        }
        return .error
    }
    
    func positionToLeft() -> Position {
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
    
    func positionToRight() -> Position {
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
    
    func positionAcross() -> Position {
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
}
