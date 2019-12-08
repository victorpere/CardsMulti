//
//  Games.swift
//  CardsMulti
//
//  Created by Victor on 2019-12-05.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import Foundation

enum Games: Int, CaseIterable {
    case FreePlay = 0
    case Solitare = 1
    
    var name: String {
        switch self {
        case .FreePlay:
            return "Free Play"
        case .Solitare:
            return "Solitaire"
        }
    }
}
