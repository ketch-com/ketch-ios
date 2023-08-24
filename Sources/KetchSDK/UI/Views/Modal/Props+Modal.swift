//
//  Props+Modal.swift
//  KetchSDK
//

import SwiftUI

extension Props {
    struct Modal {
        let title: String
        let showCloseIcon: Bool
        let purposes: PurposesList
        let saveButton: Button?
        let theme: Theme
        let localizedStrings: KetchSDK.Configuration.Translations?

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let headerBackgroundColor: Color
            let headerTextColor: Color
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
            let switchOffColor: Color
            let switchOnColor: Color

            let borderRadius: Int

            let firstButtonBackgroundColor: Color
            let firstButtonBorderColor: Color
            let firstButtonTextColor: Color
            
            let showWatermark: Bool
            let purposeButtonsLookIdentical: Bool
        }
    }
}
