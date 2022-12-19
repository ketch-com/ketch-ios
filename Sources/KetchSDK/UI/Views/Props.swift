//
//  Props.swift
//  KetchSDK
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
            borderRadius: borderRadius,
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
            borderRadius: borderRadius,
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }

    var secondaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: secondButtonBackgroundColor,
            borderColor: secondButtonBorderColor,
            backgroundColor: secondButtonTextColor
        )
    }

    var dataRightsTheme: Props.DataRightsView.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor,
            borderRadius: borderRadius,
            firstButtonBackgroundColor: firstButtonBackgroundColor,
            firstButtonBorderColor: firstButtonBorderColor,
            firstButtonTextColor: firstButtonTextColor,
            secondButtonBackgroundColor: secondButtonBackgroundColor,
            secondButtonBorderColor: secondButtonBorderColor,
            secondButtonTextColor: secondButtonTextColor
        )
    }
}

extension Props.DataRightsView.Theme {
    var firstButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }

    var secondaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: secondButtonBackgroundColor,
            borderColor: secondButtonBorderColor,
            backgroundColor: secondButtonTextColor
        )
    }
}

extension Props.SubmittedDataRightsView.Theme {
    var firstButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }

    var secondaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: secondButtonBackgroundColor,
            borderColor: secondButtonBorderColor,
            backgroundColor: secondButtonTextColor
        )
    }
}

extension Props.Jit.Theme {
    var vendorListTheme: Props.VendorList.Theme {
        .init(
            bodyBackgroundColor: backgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.Jit.Theme {
    var categoryListTheme: Props.CategoryList.Theme {
        .init(
            bodyBackgroundColor: backgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}
