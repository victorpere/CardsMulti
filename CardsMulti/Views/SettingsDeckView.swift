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
    var editable: Bool
    
    @State private var newDeckAlert = false
    
    @State private var temp: String = ""
    
    var body: some View {
        Form {
            Section {
                List {
                    ForEach(CardDecks.instance.decks.filter { $0 == self.selectedDeck || self.editable }, id: \.self.name) { deck in
                        PickerCellView(value: deck, selectedValue: self.$selectedDeck) {
                            Text(deck.name.localized)
                            if !deck.editable {
                                Image(systemName: "lock")
                            }
                        }
                        .disabled(!self.editable)
                        .swipeActions() {
                            if deck.editable {
                                Button(role: .destructive) {
                                    CardDecks.instance.delete(deck: deck)
                                    if deck == self.selectedDeck, let firstDeck = CardDecks.instance.decks.first {
                                        self.selectedDeck = firstDeck
                                    }
                                } label: {
                                    Label("delete".localized, systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                if self.editable {
                    Button("add new".localized) {
                        self.newDeckAlert = true
                    }
                    .alert("add new deck", isPresented: self.$newDeckAlert, actions: {
                        TextField("deck name", text: $temp)
                        Button("ok".localized, action: {
                            let newDeck = CardDeck(cards: Card.allCards, name: temp, editable: true)
                            CardDecks.instance.save(deck: newDeck)
                            self.selectedDeck = newDeck
                        })
                        Button("cancel".localized, role: .cancel, action: {})
                    }, message: {
                        Text("deck name")
                    })
                }
            }
            
            Section {
                if #available(iOS 16.0, *) {
                    Grid {
                        ForEach(Rank.allCases, id: \.self) { rank in
                            GridRow {
                                ForEach(Suit.allCases, id: \.self) { suit in
                                    let card = Card(suit: suit, rank: rank)
                                    CardSelectView(deck: $selectedDeck, card: card)
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
