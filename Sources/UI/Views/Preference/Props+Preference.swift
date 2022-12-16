//
//  Props+Preference.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

extension Props {
    struct Preference {
        let title: String
        let overview: OverviewTab
        let consents: ConsentsTab
        let rights:   RightsTab
        let theme: Theme

        struct OverviewTab: Identifiable, Hashable {
            var id: String { tabName }

            let tabName: String
            let title: String?
            let text: String?
        }

        struct ConsentsTab: Identifiable {
            var id: String { tabName }

            let tabName: String
            let buttonText: String
            let purposes: PurposesList
        }

        struct RightsTab: Identifiable, Hashable {
            var id: String { tabName }

            let tabName: String
            let title: String?
            let text: String?
            let buttonText: String
            let rights: [DataRightsView.Right]
        }

        struct Right: Hashable {
            let code: String?
            let name: String?
            let description: String?
        }

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let headerBackgroundColor: Color
            let headerTextColor: Color
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
            let switchOffColor: Color
            let switchOnColor: Color

            let borderRadius: Int

            let firstButtonBackgroundColor: Color
            let firstButtonBorderColor: Color
            let firstButtonTextColor: Color

            let secondButtonBackgroundColor: Color
            let secondButtonBorderColor: Color
            let secondButtonTextColor: Color
        }

        enum Tab: String, Identifiable, Hashable, CaseIterable {
            case overview
            case consents
            case rights

            var id: String { rawValue }
        }

        func tabName(with tab: Tab) -> String {
            switch tab {
            case .overview: return overview.tabName
            case .consents: return consents.tabName
            case .rights: return rights.tabName
            }
        }
    }
}

extension KetchSDK.Configuration.Right {
    var props: Props.DataRightsView.Right {
        .init(
            code: code,
            name: name,
            description: description
        )
    }
}
