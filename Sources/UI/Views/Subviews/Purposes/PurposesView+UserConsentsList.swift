//
//  PurposesView+UserConsentsList.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

class UserConsents: ObservableObject {
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

extension UserConsents {
    struct PurposeConsent: Hashable, Identifiable {
        var id: String { purpose.id }
        var consent: Bool
        let isRequired: Bool
        let requiresDisplay: Bool
        let purpose: Props.Purpose
    }

    struct VendorConsent: Hashable, Identifiable {
        var id: String { vendor.id }
        var isAccepted: Bool
        let vendor: Props.Vendor
    }
}

extension Props.Jit {
    func generateConsents() -> UserConsents {
        UserConsents(
            purposeConsents: [],
            vendorConsents: vendors.map { vendor in
                UserConsents.VendorConsent(isAccepted: vendor.isAccepted, vendor: vendor)
            }
        )
    }
}

extension Props.PurposesList {
    func generateConsents() -> UserConsents {
        UserConsents(
            purposeConsents: purposes.map { purpose in
                UserConsents.PurposeConsent(
                    consent: purpose.consent || purpose.required,
                    isRequired: purpose.required,
                    requiresDisplay: purpose.requiresDisplay,
                    purpose: purpose
                )
            },
            vendorConsents: vendors.map { vendor in
                UserConsents.VendorConsent(isAccepted: vendor.isAccepted, vendor: vendor)
            }
        )
    }
}
