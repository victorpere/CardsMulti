//
//  CardDecks.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-18.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation

class CardDecks {
    
    public static let instance = CardDecks()
    
    public let decks: [CardDeck]
    
    private init() {
        let decoder = JSONDecoder()
        if let filePath = Config.cardDecksFilePath, let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)), let decks = try? decoder.decode([CardDeck].self, from: data) {
            self.decks = decks
        } else {
            self.decks = []
        }
    }
    
    /// Returns a deck by the specified name, if exists
    func deck(named deckName: String) -> CardDeck? {
        return self.decks.first { $0.name == deckName }
    }
}
