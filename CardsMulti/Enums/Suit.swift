//
//  Suit.swift
//  durak1
//
//  Created by Victor on 2017-01-28.
//  Copyright © 2017 Victor. All rights reserved.
//

enum Suit: Int, CaseIterable, Codable {
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
    
    var unicode: String {
        switch self {
        case .spades:
            return "1f0a"
        case .hearts:
            return "1f0b"
        case .diamonds:
            return "1f0c"
        case .clubs:
            return "1f0d"
        }
    }
}

enum SuitColor: Int {
    case black, red
}
