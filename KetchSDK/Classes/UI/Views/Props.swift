//
//  Props.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 06.12.2022.
//

import SwiftUI

enum Props { }

extension Props.Modal.Theme {
    var purposesListTheme: Props.PurposesList.Theme {
        .init(
            bodyBackgroundColor: .white,
            contentColor: contentColor,
            linkColor: contentColor
        )
    }

    var firstButtonTheme: Props.Button.Theme {
        .init(
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }
}

extension Props.PurposesList.Theme {
    var vendorListTheme: Props.VendorList.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.PurposesList.Theme {
    var categoryListTheme: Props.CategoryList.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.Preference.Theme {
    var purposesListTheme: Props.PurposesList.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }

    var firstButtonTheme: Props.Button.Theme {
        .init(
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }

    var dataRightsTheme: Props.DataRightsView.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}
