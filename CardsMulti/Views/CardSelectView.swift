//
//  CardSelectView.swift
//  CardsMulti
//
//  Created by Victor on 2024-01-10.
//  Copyright © 2024 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct CardSelectView: View {
    @Binding var selected: [Card: Bool]
    
    let card: Card
    
    var color: Color {
        if self.selected[self.card] ?? false {
            return self.card.suit.uiColor
        }
        
        return self.card.suit.uiColor.opacity(0.2)
    }
    
    var body: some View {
        Text(self.card.unicode).foregroundColor(self.color)
            .font(.system(size: 100))
            .onTapGesture {
                withAnimation() {
                    self.selected[self.card] = !(self.selected[self.card] ?? false)
                }
            }
    }
}

