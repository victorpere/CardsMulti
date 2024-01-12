//
//  SettingsDeckView.swift
//  CardsMulti
//
//  Created by Victor on 2024-01-09.
//  Copyright © 2024 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct SettingsDeckView: View {
    @Binding var selectedDeck: CardDeck
    
    @State private var cardSelected: [Card: Bool] = [:]
    
    var body: some View {
        Form {
            Section {
                List {
                    ForEach(CardDecks.instance.decks, id: \.self.name) { deck in
                        PickerCellView(value: deck, selectedValue: self.$selectedDeck) {
                            Text(deck.name.localized)
                        }
                    }
                }
                Text("add new...")
            }
            
            Section {
                if #available(iOS 16.0, *) {
                    Grid {
                        ForEach(Rank.allCases, id: \.self) { rank in
                            GridRow {
                                ForEach(Suit.allCases, id: \.self) { suit in
                                    let card = Card(suit: suit, rank: rank)
                                    CardSelectView(selected: $cardSelected, card: card)
                                }
                            }
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}
