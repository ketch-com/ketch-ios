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
        let privacyPolicy: Tab
        let preferences: PreferencesTab
        let dataRights: Tab
        let theme: Theme

        enum TabType: String, Identifiable, Hashable, CaseIterable {
            case privacyPolicy
            case preferences
            case dataRights

            var id: String { rawValue }
        }

        struct Tab: Identifiable, Hashable {
            var id: String { tabName }

            let tabName: String
            let title: String?
            let text: String?
        }

        struct PreferencesTab: Identifiable {
            var id: String { tabName }

            let tabName: String
            let purposes: PurposesList
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
        }

        func tabTitle(with tab: TabType) -> String {
            switch tab {
            case .privacyPolicy: return privacyPolicy.tabName
            case .preferences: return preferences.tabName
            case .dataRights: return dataRights.tabName
            }
        }
    }
}
