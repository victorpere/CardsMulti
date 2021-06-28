//
//  Settings.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-26.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

protocol Settings {
    
    var game: Int { get set }
    var minRank: Int { get set }
    var maxRank: Int { get set }
    var pips: Bool { get set }
    var jack: Bool { get set }
    var queen: Bool { get set }
    var king: Bool { get set }
    var ace: Bool { get set }
    var cardWidthsPerScreen: Float { get set }
}
