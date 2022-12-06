//
//  Props+Modal.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
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

    struct Modal {
        let title: String
        let showCloseIcon: Bool
        let purposes: PurposesList
        let saveButton: Button?
        let theme: Theme

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
    }
}

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

extension Props {
    struct Theme {
        let buttonBorderRadius: Int

        let bannerBackgroundColor: Color
        let bannerContentColor: Color
        let bannerButtonColor: Color
        let bannerSecondaryButtonColor: Color

        let modalHeaderBackgroundColor: Color
        let modalHeaderContentColor: Color
        let modalContentColor: Color
        let modalButtonColor: Color
        let modalSwitchOffColor: Color
        let modalSwitchOnColor: Color

        let lightboxRibbonColor: Color
        let formHeaderColor: Color
        let statusColor: Color
        let highlightColor: Color
        let feedbackColor: Color
        let font: Color

        let formHeaderBackgroundColor: Color
        let formHeaderContentColor: Color
        let formContentColor: Color
        let formButtonColor: Color
        let formSwitchOffColor: Color
        let formSwitchOnColor: Color

        let titleFontSize: CGFloat = 20
        let textFontSize: CGFloat = 14
        let buttonHeight: CGFloat = 44
        let buttonBorderWidth: CGFloat = 1
    }
}

extension Props {
    struct PurposesList {
        let bodyTitle: String
        let bodyDescription: String
        let consentTitle: String?
        let purposes: [Purpose]
        let vendors: [Vendor]
        let theme: Theme

        struct Theme {
            let textFontSize: CGFloat = 14
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }
}

extension Props {
    struct Purpose: Hashable, Identifiable {
        let code: String
        let consent: Bool
        let required: Bool
        let id: String = UUID().uuidString
        let title: String
        let legalBasisName: String?
        let purposeDescription: String
        let legalBasisDescription: String?
        let categories: [Category]
    }
}

extension Props {
    struct VendorList {
        let title: String
        let description: String
        let theme: Theme

        struct Theme {
            let textFontSize: CGFloat = 14
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }
}

extension Props {
    struct Vendor: Hashable, Identifiable {
        let id: String
        let name: String
        let isAccepted: Bool
        let purposes: [VendorPurpose]?
        let specialPurposes: [VendorPurpose]?
        let features: [VendorPurpose]?
        let specialFeatures: [VendorPurpose]?
        let policyUrl: URL?
    }

    struct VendorPurpose: Hashable, Identifiable {
        var id: String { name }

        let name: String
        let legalBasis: String?
    }
}

extension Props {
    struct CategoryList {
        let title: String
        let description: String
        let theme: Theme
        let categories: [Category]

        struct Theme {
            let textFontSize: CGFloat = 14
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }

    struct Category: Hashable, Identifiable {
        var id: String { name }

        let name: String
        let retentionPeriod: String
        let externalTransfers: String
        let description: String
    }
}

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
