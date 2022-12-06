//
//  Props+Button.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
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

            let textColor: Color
            let borderColor: Color
            let backgroundColor: Color
        }
    }
}
