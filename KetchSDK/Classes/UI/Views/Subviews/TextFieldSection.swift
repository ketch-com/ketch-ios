//
//  TextFieldSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 09.12.2022.
//

import SwiftUI

struct TextFieldSection: View {
    let title: String?
    let hint: String?
    let accentColor: Color
    var value: Binding<String>

    @State private var color: Color = .black

    init(title: String?, hint: String?, accentColor: Color, value: Binding<String>) {
        self.title = title
        self.hint = hint
        self.accentColor = accentColor
        self.value = value
        self.color = accentColor
    }

    var body: some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                    Spacer()
                }
            }

            TextField(hint ?? "", text: value, onEditingChanged: { changed in
                if changed {
                    color = .orange
                }
                else {
                    color = accentColor
                }
              })
                .font(.system(size: 14))
                .frame(height: 44)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(color, lineWidth: 1)
                )
        }
    }
}

