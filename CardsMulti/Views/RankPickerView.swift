//
//  CardPickerView.swift
//  CardsMulti
//
//  Created by Victor on 2023-10-08.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct RankPickerView: View {
    @State var selectedRank: Rank = .two
    @Environment(\.dismiss) private var dismiss
    var submitAction: ((Rank) -> Void)?
    
    var body: some View {
        VStack {
            Picker("", selection: self.$selectedRank) {
                ForEach(Rank.allCases, id: \.self) { rank in
                    Text(rank.symbol)
                }
            }.pickerStyle(.segmented)
            Spacer()
            Button("submit") {
                self.submitAction?(self.selectedRank)
                dismiss()
            }.buttonStyle(.borderedProminent)
        }
    }
}
