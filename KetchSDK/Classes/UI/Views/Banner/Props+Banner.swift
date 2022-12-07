//
//  Props+Banner.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

extension Props {
    struct Banner {
        let title: String
        let text: String
        let primaryButton: Button?
        let secondaryButton: Button?
        let theme: Theme

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let contentColor: Color
            let backgroundColor: Color
            let linkColor: Color
            let borderRadius: Int

            let buttonColor: Color
            let secondaryButtonColor: Color
        }
    }
}
