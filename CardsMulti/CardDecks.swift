//
//  CardDecks.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-18.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import Foundation

class CardDecks {
    
    static let instance = CardDecks()
    
    @StoredEncodedWithDefault (key: "customDecks", defaultValue: []) private var customDecks: [CardDeck]
    
    private let definedDecks: [CardDeck]
    
    var decks: [CardDeck] { self.definedDecks + self.customDecks }
    
    private init() {
        let decoder = JSONDecoder()
        if let filePath = Config.cardDecksFilePath, let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)), let decks = try? decoder.decode([CardDeck].self, from: data) {
            self.definedDecks = decks
        } else {
            self.definedDecks = []
        }
    }
    
    /// Returns a deck by the specified name, if exists
    func deck(named deckName: String) -> CardDeck? {
        return self.decks.first { $0.name == deckName }
    }
    
    /// Saves custom deck
    func save(deck: CardDeck) {
        if deck.editable {
            if let i = self.customDecks.firstIndex(where: { $0.name == deck.name && $0.editable }) {
                self.customDecks[i] = deck
            } else {
                self.customDecks.append(deck)
            }
        }
    }
    
    /// Deletes custom deck
    func delete(deck: CardDeck) {
        if deck.editable {
            self.customDecks.removeAll { $0.name == deck.name }
        }
    }
}
