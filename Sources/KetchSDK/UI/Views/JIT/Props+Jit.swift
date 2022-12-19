//
//  Props+Jit.swift
//  KetchSDK
//

import SwiftUI

extension Props {
    struct Jit {
        let title: String?
        let showCloseIcon: Bool
        let description: String?
        let purpose: Purpose
        let vendors: [Vendor]
        let acceptButtonText: String
        let declineButtonText: String
        let moreInfoText: String?
        let moreInfoDestinationEnabled: Bool
        let theme: Theme

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let headerBackgroundColor: Color
            let headerTextColor: Color
            let backgroundColor: Color
            let contentColor: Color
            let linkColor: Color
            let switchOffColor: Color
            let switchOnColor: Color

            let borderRadius: Int

            let firstButtonBackgroundColor: Color
            let firstButtonBorderColor: Color
            let firstButtonTextColor: Color

            let secondButtonBackgroundColor: Color
            let secondButtonBorderColor: Color
            let secondButtonTextColor: Color
        }
    }
}
