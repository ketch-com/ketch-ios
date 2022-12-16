//
//  TitleDescriptionSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

struct TitleDescriptionSection: View {
    enum Action {
        case openUrl(URL)
    }

    let props: Props.TitleDescriptionSection
    let actionHandler: (Action) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let title = props.bodyTitle {
                Text(title)
                    .font(.system(size: props.theme.titleFontSize, weight: .bold))
                    .foregroundColor(props.theme.contentColor)
            }

            DescriptionMarkupText(description: props.bodyDescription) { url in
                actionHandler(.openUrl(url))
            }
            .font(.system(size: props.theme.textFontSize))
            .foregroundColor(props.theme.contentColor)
            .accentColor(props.theme.linkColor)
        }
    }
}

extension Props {
    struct TitleDescriptionSection {
        let bodyTitle: String?
        let bodyDescription: String
        let theme: Theme

        struct Theme {
            let titleFontSize: CGFloat = 16
            let textFontSize: CGFloat = 14
            let contentColor: Color
            let linkColor: Color
        }
    }
}

extension Props.PurposesList {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: bodyTitle,
            bodyDescription: bodyDescription,
            theme: theme.titleDescriptionSectionTheme
        )
    }
}


extension Props.VendorList {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: title,
            bodyDescription: description,
            theme: theme.titleDescriptionSectionTheme
        )
    }
}

extension Props.Preference {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: overview.title,
            bodyDescription: overview.text ?? "",
            theme: theme.titleDescriptionSectionTheme
        )
    }
}

extension Props.CategoryList {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: title,
            bodyDescription: description,
            theme: theme.titleDescriptionSectionTheme
        )
    }
}

extension Props.Banner {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: nil,
            bodyDescription: text,
            theme: theme.titleDescriptionSectionTheme
        )
    }
}

extension Props.Jit {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: nil,
            bodyDescription: description ?? "",
            theme: theme.titleDescriptionSectionTheme
        )
    }
}

extension Props.DataRightsView {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: bodyTitle,
            bodyDescription: bodyDescription ?? "",
            theme: theme.titleDescriptionSectionTheme
        )
    }

    var submittedViewProps: Props.SubmittedDataRightsView {
        .init(
            bodyTitle: "Thank You!",
            bodyDescription: """
            We have received your request and will reach out to the provided email address if we have any questions. \

            Once we have completed your request, we will send you an email to confirm.
            """,
            theme: Props.SubmittedDataRightsView.Theme(
                bodyBackgroundColor: theme.bodyBackgroundColor,
                contentColor: theme.contentColor,
                linkColor: theme.linkColor,
                borderRadius: theme.borderRadius,
                firstButtonBackgroundColor: theme.firstButtonBackgroundColor,
                firstButtonBorderColor: theme.firstButtonBorderColor,
                firstButtonTextColor: theme.firstButtonTextColor,
                secondButtonBackgroundColor: theme.secondButtonBackgroundColor,
                secondButtonBorderColor: theme.secondButtonBorderColor,
                secondButtonTextColor: theme.secondButtonTextColor
            )
        )
    }
}

extension Props.SubmittedDataRightsView {
    var titleDescriptionSectionProps: Props.TitleDescriptionSection {
        .init(
            bodyTitle: bodyTitle,
            bodyDescription: bodyDescription ?? "",
            theme: theme.titleDescriptionSectionTheme
        )
    }
}

extension Props.PurposesList.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.VendorList.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.Preference.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.CategoryList.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.Banner.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }

    var primaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: backgroundColor,
            borderColor: buttonColor,
            backgroundColor: buttonColor
        )
    }

    var secondaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: buttonColor,
            borderColor: buttonColor,
            backgroundColor: secondaryButtonColor
        )
    }
}

extension Props.Jit.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }

    var primaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: firstButtonTextColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonBackgroundColor
        )
    }

    var secondaryButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: secondButtonTextColor,
            borderColor: secondButtonBorderColor,
            backgroundColor: secondButtonBackgroundColor
        )
    }

    var thirdButtonTheme: Props.Button.Theme {
        .init(
            borderRadius: borderRadius,
            textColor: secondButtonTextColor,
            borderColor: .clear,
            backgroundColor: .clear
        )
    }
}

extension Props.DataRightsView.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.SubmittedDataRightsView.Theme {
    var titleDescriptionSectionTheme: Props.TitleDescriptionSection.Theme {
        .init(
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

