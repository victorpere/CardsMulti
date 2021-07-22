//
//  Settings.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-26.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import Foundation

protocol Settings {
    var displayName: String { get set }
    var cardSet: String? { get set }
    var game: Int { get set }
    var minRank: Int { get set }
    var maxRank: Int { get set }
    var pipsEnabled: Bool { get set }
    var jacksEnabled: Bool { get set }
    var queensEnabled: Bool { get set }
    var kingsEnabled: Bool { get set }
    var acesEnabled: Bool { get set }
    var cardWidthsPerScreen: Float { get set }
    var soundOn: Bool { get set }
    var customOptions: NSDictionary? { get set }
}
