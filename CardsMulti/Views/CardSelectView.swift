//
//  CardSelectView.swift
//  CardsMulti
//
//  Created by Victor on 2024-01-10.
//  Copyright © 2024 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct CardSelectView: View {
    @Binding var deck: CardDeck
    
    let card: Card
    
    var selected: Bool {
        self.deck.cards.contains(self.card)
    }
    
    var color: Color {
        if self.selected {
            return self.card.suit.uiColor
        }
        
        return self.card.suit.uiColor.opacity(0.2)
    }
    
    var body: some View {
        Text(self.card.unicode).foregroundColor(self.color)
            .font(.system(size: 100))
            .onTapGesture {
                withAnimation() {
                    if !self.selected {
                        self.deck.cards.append(self.card)
                    } else {
                        self.deck.cards.removeAll { $0 == self.card }
                    }
                }
            }
    }
}

