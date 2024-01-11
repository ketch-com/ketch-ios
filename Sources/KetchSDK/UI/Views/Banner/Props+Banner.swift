//
//  Props+Banner.swift
//  KetchSDK
//

import SwiftUI

extension Props {
    struct Banner {
        let title: String
        let text: String
        let primaryButton: Button?
        let secondaryButton: Button?
        let theme: Theme
        let localizedStrings: KetchSDK.LocalizedStrings

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let contentColor: Color
            let backgroundColor: Color
            let linkColor: Color
            let borderRadius: Int

            let buttonColor: Color
            let secondaryButtonColor: Color
            let secondaryButtonVariant: String
        }
    }
}