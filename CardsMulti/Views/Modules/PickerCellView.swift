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
    var confirmationAlertTitle: String?
    var pickAction: ((Int) -> Bool)?
    var confirmationAction: ((Int) -> Void)?
    
    @ViewBuilder let content: Content
    
    @State private var showingAlert = false
    
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
                if self.pickAction == nil || self.pickAction!(self.value) {
                    self.selectedValue = self.value
                } else {
                    self.showingAlert = true
                }
            }
        }) {
            HStack {
                self.content
                Spacer()
                if self.selectedValue == self.value {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }.buttonStyle(.automatic)
            .foregroundColor(.primary)
            .confirmationDialog(self.confirmationAlertTitle ?? "", isPresented: self.$showingAlert, titleVisibility: .visible) {
                Button(UIStrings.ok) {
                    self.confirmationAction?(self.value)
                }
            }
    }
}
