//
//  ModalView+UserConsentsList.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

extension ModalView {
    struct PurposeConsent: Hashable, Identifiable {
        var id: String { purpose.id }

        var consent: Bool
        let required: Bool
        let purpose: Props.Purpose
    }

    struct VendorConsent: Hashable, Identifiable {
        var id: String { vendor.id }

        var isAccepted: Bool
        let vendor: Props.Vendor
    }

    class UserConsentsList: ObservableObject {
        @Published var purposeConsents: [PurposeConsent]
        @Published var vendorConsents: [VendorConsent]

        init(
            purposeConsents: [PurposeConsent],
            vendorConsents: [VendorConsent]
        ) {
            self.purposeConsents = purposeConsents
            self.vendorConsents = vendorConsents
        }
    }
}
