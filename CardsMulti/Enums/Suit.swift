//
//  Suit.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

enum Suit: Int {
    case spades, hearts, diamonds, clubs
    var symbol: String {
        switch self {
        case .spades:
            return "♠️"
        case .hearts:
            return "♥️"
        case .diamonds:
            return "♦️"
        case .clubs:
            return "♣️"
        }
    }
    var color: SuitColor {
        switch self {
        case .spades, .clubs:
            return SuitColor.black
        case .hearts, .diamonds:
            return SuitColor.red
        }
    }
}

enum SuitColor: Int {
    case black, red
}
