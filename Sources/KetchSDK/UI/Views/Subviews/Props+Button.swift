//
//  Props+Button.swift
//  KetchSDK
//

import SwiftUI

extension Props {
    struct Button {
        let text: String
        let theme: Theme

        struct Theme {
            let fontSize: CGFloat = 14
            let height: CGFloat = 44
            let borderWidth: CGFloat = 1

            let borderRadius: Int
            let textColor: Color
            let borderColor: Color
            let backgroundColor: Color
            let buttonVariant: String = "outlined"
        }
    }
}
