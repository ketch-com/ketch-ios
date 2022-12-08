//
//  PurposesView+UserConsentsList.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

class UserConsentsList: ObservableObject {
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

    @Published var purposeConsents: [PurposeConsent]
    @Published var vendorConsents: [VendorConsent]

    init(
        purposeConsents: [PurposeConsent] = [],
        vendorConsents: [VendorConsent] = []
    ) {
        self.purposeConsents = purposeConsents
        self.vendorConsents = vendorConsents
    }
}

extension Props.PurposesList {
    var consentsList: UserConsentsList {
        UserConsentsList(
            purposeConsents: purposes.map { purpose in
                UserConsentsList.PurposeConsent(
                    consent: purpose.consent || purpose.required,
                    required: purpose.required,
                    purpose: purpose
                )
            },
            vendorConsents: vendors.map { vendor in
                UserConsentsList.VendorConsent(
                    isAccepted: vendor.isAccepted,
                    vendor: vendor
                )
            }
        )
    }
}
