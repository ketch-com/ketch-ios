//
//  TextFieldSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 09.12.2022.
//

import SwiftUI

struct TextFieldSection: View {
    let title: String
    let hint: String?
    let accentColor: Color
    let validations: [String.Validation]
    var value: Binding<String>

    @State private var color: Color = .black
    @State private var error: String?

    init(title: String, hint: String?, accentColor: Color, validations: [String.Validation] = [], value: Binding<String>) {
        self.title = title
        self.hint = hint
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

            TextField(hint ?? "", text: value, onEditingChanged: { changed in
                if changed {
                    color = .orange
                } else {
                    error = validationErrorText(for: value.wrappedValue)
                    color = error == nil ? accentColor : .red
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

    private func validationErrorText(for text: String) -> String? {
        validations.first { validation in
            validation.isValid(text) == false
        }?.errorText
    }
}

struct TextFieldSection_Preview: PreviewProvider {    
    static var previews: some View {
        Test_TextFieldSection()
            .padding(24)
    }

    private struct Test_TextFieldSection: View {
        @State var value: String = ""

        var body: some View {
            TextFieldSection(
                title: "Title",
                hint: "Hint",
                accentColor: .black,
                validations: [.notEmpty, .email],
                value: $value
            )
        }
    }
}
