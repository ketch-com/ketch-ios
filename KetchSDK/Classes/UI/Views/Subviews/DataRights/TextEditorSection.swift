//
//  TextEditorSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 09.12.2022.
//

import SwiftUI

struct TextEditorSection: View {
    let title: String?
    let accentColor: Color
    var value: Binding<String>

    @State private var color: Color = .black

    init(title: String?, accentColor: Color, value: Binding<String>) {
        self.title = title
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

            if #available(iOS 15.0, *) {
                FocusableTextEditor(
                    title: title,
                    accentColor: accentColor,
                    value: value,
                    color: $color
                )
            } else {
                TextEditor(text: value)
                    .font(.system(size: 14))
                    .frame(minHeight:80)
                    .padding(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(color, lineWidth: 1)
                    )
            }
        }
    }
}

@available(iOS 15.0, *)
private struct FocusableTextEditor: View {
    let title: String?
    let accentColor: Color
    var value: Binding<String>
    var color: Binding<Color>

    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: value)
            .focused($isFocused)
            .font(.system(size: 14))
            .frame(minHeight:80)
            .padding(6)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(color.wrappedValue, lineWidth: 1)
            )
            .onChange(of: isFocused) { focused in
                color.wrappedValue = focused ? .orange : accentColor
            }
    }
}
