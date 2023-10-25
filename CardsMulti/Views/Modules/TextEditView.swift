//
//  TextEditView.swift
//  Notifications-Form
//
//  Created by Victor on 2023-10-15.
//

import SwiftUI

struct TextEditView: View {
    @Binding var text: String
    var label: String
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("", text: self.$text) {
                
            }
                .focused(self.$focused)
                .submitLabel(.done)
        }.onAppear {
            self.focused = true
        }.navigationTitle(self.label).navigationBarTitleDisplayMode(.inline)
            .onSubmit {
                dismiss()
            }
    }
}
