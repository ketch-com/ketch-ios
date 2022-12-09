//
//  TextEditorSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 09.12.2022.
//

import SwiftUI

struct TextEditorSection: View {
    let title: String
    let accentColor: Color
    let validations: [String.Validation]
    var value: Binding<String>

    @State private var color: Color = .black
    @State private var error: String?

    init(title: String, accentColor: Color, validations: [String.Validation] = [], value: Binding<String>) {
        self.title = title
        self.accentColor = accentColor
        self.value = value
        self.color = accentColor
        self.validations = validations
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                Spacer()
                if let error = error {
                    Text(error)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
            }


            if #available(iOS 15.0, *) {
                FocusableTextEditor(
                    title: title,
                    accentColor: accentColor,
                    value: value,
                    error: $error,
                    color: $color,
                    validations: validations
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
    var error: Binding<String?>
    var color: Binding<Color>
    let validations: [String.Validation]

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
                if focused {
                    color.wrappedValue = .orange
                } else {
                    error.wrappedValue = validationErrorText(for: value.wrappedValue)
                    color.wrappedValue = error.wrappedValue == nil ? accentColor : .red
                }
            }
    }


    private func validationErrorText(for text: String) -> String? {
        validations.first { validation in
            validation.isValid(text) == false
        }?.errorText
    }
}
