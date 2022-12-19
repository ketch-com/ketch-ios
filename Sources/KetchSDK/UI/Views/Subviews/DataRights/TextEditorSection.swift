//
//  TextEditorSection.swift
//  KetchSDK
//

import SwiftUI

struct TextEditorSection: View {
    let title: String
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


            if #available(iOS 15.0, *) {
                FocusableTextEditor(
                    title: title,
                    accentColor: accentColor,
                    value: value,
                    error: error,
                    isChanged: $isChanged,
                    color: color
                )
            } else {
                TextField("", text: value, onEditingChanged: { changed in
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
}

@available(iOS 15.0, *)
private struct FocusableTextEditor: View {
    let title: String?
    let accentColor: Color
    var value: Binding<String>
    var error: Binding<String?>
    var isChanged: Binding<Bool>
    var color: Color

    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: value)
            .focused($isFocused)
            .font(.system(size: 14))
            .frame(minHeight:80)
            .padding(6)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(color, lineWidth: 1)
            )
            .onChange(of: isFocused) { focused in
                isChanged.wrappedValue = focused
            }
    }
}
