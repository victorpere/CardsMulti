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
    
    var body: some View {
        List {
            ForEach(CardDecks.instance.decks, id: \.self.name) { deck in
                PickerCellView(value: deck, selectedValue: self.$selectedDeck) {
                    Text(deck.name.localized)
                }
            }
        }
    }
}
