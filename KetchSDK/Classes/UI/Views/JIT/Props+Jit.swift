//
//  Props+Jit.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 11.12.2022.
//

import SwiftUI

extension Props {
    struct Jit {
        let title: String?
        let showCloseIcon: Bool
        let description: String?
        let purpose: Purpose?
        let vendors: [Vendor]?
        let acceptButtonText: String
        let declineButtonText: String
        let moreInfoText: String?
        let moreInfoDestination: Destination?
        let theme: Theme

        struct Purpose: Hashable, Identifiable {
            let id = UUID()
            let title: String
            let legalBasisName: String?
            let purposeDescription: String
            let legalBasisDescription: String?
            let categories: [Category]
        }

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let headerBackgroundColor: Color
            let headerTextColor: Color
            let backgroundColor: Color
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
    }

    enum Destination {
        case modal
        case preference
        case rejectAll
    }
}

extension Props.Jit {
//    func generateConsentsList() -> UserConsentsList {
//        UserConsentsList(
//            purposeConsents: [purpose].map { purpose in
//                UserConsentsList.PurposeConsent(
//                    consent: purpose.consent || purpose.required,
//                    required: purpose.required,
//                    purpose: purpose
//                )
//            },
//            vendorConsents: vendors.map { vendor in
//                UserConsentsList.VendorConsent(
//                    isAccepted: vendor.isAccepted,
//                    vendor: vendor
//                )
//            }
//        )
//    }
}
