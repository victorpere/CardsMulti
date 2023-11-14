//
//  Rank.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

enum Rank: Int, CaseIterable, Codable {
    case two = 2, three,four, five
    case six, seven, eight, nine, ten
    case jack, queen, king
    case ace
    var symbol: String {
        switch self {
        case .ace:
            return "A"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        default:
            return String(self.rawValue)
        }
    }
    var name: String {
        switch self {
        case .ace:
            return "ace"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        default:
            return String(self.rawValue)
        }
    }
}
