//
//  SubmittedDataRightsView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 09.12.2022.
//

import SwiftUI

struct SubmittedDataRightsView: View {
    enum Action {
        case close
        case submitNew
        case openUrl(URL)
    }

    let props: Props.SubmittedDataRightsView
    let actionHandler: (Action) -> Void
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack(spacing: 24) {
            ScrollView(showsIndicators: true) {
                TitleDescriptionSection(
                    props: props.titleDescriptionSectionProps
                ) { action in
                    switch action {
                    case .openUrl(let url): actionHandler(.openUrl(url))
                    }
                }
            }

            Spacer()

            bottomButtonsSection()
        }
        .padding(18)
        .padding(.bottom, 40)
        .background(props.theme.bodyBackgroundColor)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func bottomButtonsSection() -> some View {
        VStack(spacing: 24) {
            CustomButton(
                props: .init(text: "Exit Settings", theme: props.theme.firstButtonTheme)
            ) {
                actionHandler(.close)
                presentationMode.wrappedValue.dismiss()
            }

            CustomButton(
                props: .init(text: "Submit New Request", theme: props.theme.secondaryButtonTheme)
            ) {
                actionHandler(.submitNew)
            }
        }
    }
}

extension Props {
    struct SubmittedDataRightsView {
        let bodyTitle: String?
        let bodyDescription: String?
        let theme: Theme

        struct Theme {
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
