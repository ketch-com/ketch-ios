//
//  Props+Theme.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

extension Props {
    struct Theme {
        let buttonBorderRadius: Int

        let bannerBackgroundColor: Color
        let bannerContentColor: Color
        let bannerButtonColor: Color
        let bannerSecondaryButtonColor: Color

        let modalHeaderBackgroundColor: Color
        let modalHeaderContentColor: Color
        let modalContentColor: Color
        let modalButtonColor: Color
        let modalSwitchOffColor: Color
        let modalSwitchOnColor: Color

        let lightboxRibbonColor: Color
        let formHeaderColor: Color
        let statusColor: Color
        let highlightColor: Color
        let feedbackColor: Color
        let font: Color

        let formHeaderBackgroundColor: Color
        let formHeaderContentColor: Color
        let formContentColor: Color
        let formButtonColor: Color
        let formSwitchOffColor: Color
        let formSwitchOnColor: Color

        let titleFontSize: CGFloat = 20
        let textFontSize: CGFloat = 14
        let buttonHeight: CGFloat = 44
        let buttonBorderWidth: CGFloat = 1
    }
}
