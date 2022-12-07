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

extension Props.Banner.Theme {
    init(with theme: KetchSDK.Configuration.Theme?) {
        let bannerBackgroundColor = Color(hex: theme?.bannerBackgroundColor ?? String())
        let bannerButtonColor = Color(hex: theme?.bannerButtonColor ?? String())
        let bannerSecondaryButtonColor = Color(hex: theme?.bannerSecondaryButtonColor ?? String())
        let bannerContentColor = Color(hex: theme?.bannerContentColor ?? String())

        self.init(
            contentColor: bannerContentColor,
            backgroundColor: bannerBackgroundColor,
            linkColor: bannerButtonColor,
            borderRadius: theme?.buttonBorderRadius ?? 0,
            buttonColor: bannerButtonColor,
            secondaryButtonColor: bannerSecondaryButtonColor
        )
    }
}

extension Props.Modal.Theme {
    init(with theme: KetchSDK.Configuration.Theme?) {
        let modalHeaderBackgroundColor = Color(hex: theme?.modalHeaderBackgroundColor ?? String())
        let modalHeaderContentColor = Color(hex: theme?.modalHeaderContentColor ?? String())
        let modalContentColor = Color(hex: theme?.modalContentColor ?? String())
        let switchOffColor = Color(hex: theme?.modalSwitchOffColor ?? "#7C868D")
        let switchOnColor = Color(hex: theme?.modalSwitchOnColor ?? theme?.modalContentColor ?? String())

        let firstButtonBackgroundColor = Color(hex: theme?.modalButtonColor ?? String())
        let firstButtonBorderColor = Color(hex: theme?.modalButtonColor ?? String())
        let firstButtonTextColor = Color(hex: theme?.modalHeaderBackgroundColor ?? String())

        self.init(
            headerBackgroundColor: modalHeaderBackgroundColor,
            headerTextColor: modalHeaderContentColor,
            bodyBackgroundColor: .white,
            contentColor: modalContentColor,
            linkColor: modalContentColor,
            switchOffColor: switchOffColor,
            switchOnColor: switchOnColor,
            borderRadius: theme?.buttonBorderRadius ?? 0,
            firstButtonBackgroundColor: firstButtonBackgroundColor,
            firstButtonBorderColor: firstButtonBorderColor,
            firstButtonTextColor: firstButtonTextColor
        )
    }
}

extension Props.Preference.Theme {
    init(with theme: KetchSDK.Configuration.Theme?) {
        let headerBackgroundColor = Color(hex: theme?.formHeaderBackgroundColor ?? String())
        let headerContentColor = Color(hex: theme?.formHeaderContentColor ?? String())

        let contentColor = Color(hex: theme?.formContentColor ?? String())
        let bodyBackgroundColor = Color.white

        let switchOffColor = Color(hex: theme?.formSwitchOffColor ?? "#7C868D")
        let switchOnColor = Color(hex: theme?.formSwitchOnColor ?? theme?.formContentColor ?? String())

        let firstButtonBackgroundColor = Color(hex: theme?.formButtonColor ?? String())
        let firstButtonBorderColor = Color(hex: theme?.formButtonColor ?? String())
        let firstButtonTextColor = Color.white

        let secondButtonBackgroundColor = Color.white
        let secondButtonBorderColor = Color(hex: theme?.formButtonColor ?? String())
        let secondButtonTextColor = Color(hex: theme?.formButtonColor ?? String())

        self.init(
            headerBackgroundColor: headerBackgroundColor,
            headerTextColor: headerContentColor,
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: firstButtonBackgroundColor,
            switchOffColor: switchOffColor,
            switchOnColor: switchOnColor,
            borderRadius: theme?.buttonBorderRadius ?? 0,
            firstButtonBackgroundColor: firstButtonBackgroundColor,
            firstButtonBorderColor: firstButtonBorderColor,
            firstButtonTextColor: firstButtonTextColor,
            secondButtonBackgroundColor: secondButtonBackgroundColor,
            secondButtonBorderColor: secondButtonBorderColor,
            secondButtonTextColor: secondButtonTextColor
        )
    }
}

//private
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
