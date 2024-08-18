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
    
    private var cardImage: UIImage? {
        UIImage(named: self.card.spriteName)
    }
    
    var body: some View {
        if let cardImage = self.cardImage {
            Image(uiImage: cardImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(self.selected ? 1 : 0.2)
                .onTapGesture {
                    if self.deck.editable {
                        withAnimation() {
                            if !self.selected {
                                self.deck.cards.append(self.card)
                            } else {
                                self.deck.cards.removeAll { $0 == self.card }
                            }
                        }
                        
                        DispatchQueue.global(qos: .background).async {
                            CardDecks.instance.save(deck: self.deck)
                        }
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 2)
                .stroke(self.color, lineWidth: 0.5))
        }
    }
}

