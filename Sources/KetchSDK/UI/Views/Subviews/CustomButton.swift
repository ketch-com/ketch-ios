//
//  CustomButton.swift
//  KetchSDK
//

import SwiftUI

struct CustomButton:View {
    let props: Props.Button
    let actionHandler:  () -> Void

    var body: some View {
        Button {
            actionHandler()
        } label: {
            Text(props.text)
                .font(.system(size: props.theme.fontSize, weight: .semibold))
                .foregroundColor(props.theme.textColor)
                .frame(height: props.theme.height)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(props.theme.borderRadius))
                        .stroke(
                            props.theme.borderColor,
                            lineWidth: props.theme.borderWidth
                        )
                )
        }
        .background(
            props.theme.backgroundColor
                .cornerRadius(CGFloat(props.theme.borderRadius))
        )
    }
}

