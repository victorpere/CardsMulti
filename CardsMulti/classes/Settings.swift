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
    var cardWidthsPerScreen: Float { get set }
    var margin: Float { get set }
    var soundOn: Bool { get set }
    var customOptions: NSDictionary? { get set }
    var deck: CardDeck { get set }
}

protocol GameSettings {
    var cardWidthsPerScreen: Float { get set }
    var margin: Float { get set }
    var customOptions: NSDictionary? { get set }
    var deck: CardDeck { get set }
}
