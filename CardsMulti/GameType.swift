//
//  Games.swift
//  CardsMulti
//
//  Created by Victor on 2019-12-05.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

enum GameType: Int, CaseIterable {
    case freePlay = 0
    case solitare = 1
    //case GoFish = 2
    case freeCell = 2
    
    init(withName name: String) throws {
        switch name {
        case "FreePlay":
            self = .freePlay
            break
        case "Solitaire":
            self = .solitare
            break
        case "FreeCell":
            self = .freeCell
            break
        default:
            throw GameTypeError.FailedToFindGameTypeError
        }
    }
    
    var name: String {
        switch self {
        case .freePlay:
            return "free play".localized
        case .solitare:
            return "solitaire".localized
//        case .GoFish:
//            return "Go Fish"
        case .freeCell:
            return "freecell".localized
        }
    }
}

enum GameTypeError : Error {
    case FailedToFindGameTypeError
}
