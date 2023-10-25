//
//  PickerCellView.swift
//  CardsMulti
//
//  Created by Victor on 2023-10-23.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct PickerCellView<Content: View>: View {
    var value: Int
    @Binding var selectedValue: Int
    @ViewBuilder let content: Content
    
    func rightContent<RightContent: View>(@ViewBuilder _ rightContent: () -> RightContent) -> some View {
        HStack {
            self
            Spacer()
            rightContent()
        }
    }
    
    var body: some View {
        Button(action: {
            if self.selectedValue != self.value {
                self.selectedValue = self.value
            }
        }) {
            HStack {
                self.content
                Spacer()
                if self.selectedValue == self.value {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
//                        .fontWeight(.semibold)
                }
            }
        }.buttonStyle(.automatic)
            .foregroundColor(.primary)
    }
}
