//
//  Props+Banner.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

extension Props {
    struct Banner {
        let theme: Theme

        struct Theme {
            let bannerBackgroundColor: Color
            let bannerContentColor: Color
            let bannerButtonColor: Color
            let bannerSecondaryButtonColor: Color
        }
    }
}
