//
//  DataRightsView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

struct DataRightsView: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.DataRightsView
    let actionHandler: (Action) -> Void

    var body: some View {
        ScrollView(showsIndicators: true) {
            TitleDescriptionSection(
                props: props.titleDescriptionSectionProps
            ) { action in
                switch action {
                case .openUrl(let url): actionHandler(.openUrl(url))
                }
            }
            .padding(18)

            userForm()
        }
        .background(props.theme.bodyBackgroundColor)
    }

    @ViewBuilder
    private func userForm() -> some View {
        Spacer()
    }
}

extension Props {
    struct DataRightsView {
        let bodyTitle: String?
        let bodyDescription: String?
        let theme: Theme

        struct Theme {
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }
}
