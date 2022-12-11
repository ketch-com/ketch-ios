//
//  DataRightsView+Props.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 11.12.2022.
//

import SwiftUI

extension Props {
    struct DataRightsView {
        let bodyTitle: String?
        let bodyDescription: String?
        let theme: Theme
        let rights: [Right]

        struct Right: Hashable, RightDescription {
            let code: String
            let name: String
            let description: String
        }

        struct Theme {
            let titleFontSize: CGFloat = 16

            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color

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
