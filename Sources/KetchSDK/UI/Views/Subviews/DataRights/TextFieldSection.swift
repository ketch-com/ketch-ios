//
//  TextFieldSection.swift
//  KetchSDK
//

import SwiftUI

struct TextFieldSection: View {
    let title: String
    let hint: String?
    let accentColor: Color
    let error: Binding<String?>
    let value: Binding<String>

    @State private var isChanged = false

    var color: Color {
        if isChanged {
            return .orange
        } else {
            return error.wrappedValue == nil ? accentColor : .red
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                Spacer()
                if let error = error.wrappedValue, isChanged == false {
                    Text(error)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
            }

            TextField(hint ?? "", text: value, onEditingChanged: { changed in
                isChanged = changed
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

struct TextFieldSection_Preview: PreviewProvider {    
    static var previews: some View {
        Test_TextFieldSection()
            .padding(24)
    }

    private struct Test_TextFieldSection: View {
        @State var value: String = ""
        @State var error: String? = "Required"

        var body: some View {
            TextFieldSection(
                title: "Title",
                hint: "Hint",
                accentColor: .black,
                error: $error,
                value: $value
            )
        }
    }
}
