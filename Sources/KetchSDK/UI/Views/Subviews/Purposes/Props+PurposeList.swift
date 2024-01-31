//
//  Props+PurposeList.swift
//  KetchSDK
//

import SwiftUI

extension Props {
    struct PurposesList {
        let bodyTitle: String
        let bodyDescription: String
        let consentTitle: String?
        let purposes: [Purpose]
        let vendors: [Vendor]
        let theme: Theme
        let purposeButtonsLookIdentical: Bool

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
        let requiresDisplay: Bool
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

extension KetchSDK.Configuration.Purpose {
    var needsDisplay: Bool { requiresDisplay ?? false }

    var isRequired: Bool { (allowsOptOut ?? false) == false }

    var requiresAccept: Bool { requiresOptIn ?? false }

    var defaultConsent: Bool { !needsDisplay || isRequired || !requiresAccept }
}

extension Props.PurposesList {
    init(
        bodyTitle: String,
        bodyDescription: String,
        consentTitle: String?,
        hideConsentTitle: Bool = false,
        hideLegalBases: Bool = false,
        purposes: [KetchSDK.Configuration.Purpose]?,
        vendors: [KetchSDK.Configuration.Vendor]?,
        purposesConsent: [String: Bool],
        vendorsConsent: [String]?,
        theme: Theme,
        purposeButtonsLookIdentical: Bool
    ) {
        let purposes: [Props.Purpose]? = purposes?.map { purpose in
            Props.Purpose(
                with: purpose,
                consent: purposesConsent[purpose.code] ?? purpose.defaultConsent,
                legalBasisName: hideLegalBases ? nil : purpose.legalBasisName,
                legalBasisDescription: hideLegalBases ? nil : purpose.legalBasisDescription
            )
        }

        let vendors = vendors?.map { vendor in
            Props.Vendor(
                with: vendor,
                consent: vendorsConsent?.contains(vendor.id) ?? false
            )
        }

        self.init(
            bodyTitle: bodyTitle,
            bodyDescription: bodyDescription,
            consentTitle: hideConsentTitle ? "" : consentTitle,
            purposes: purposes ?? [],
            vendors: vendors ?? [],
            theme: theme,
            purposeButtonsLookIdentical: purposeButtonsLookIdentical
        )
    }
}

extension Props.Purpose {
    init(
        with purpose: KetchSDK.Configuration.Purpose,
        consent: Bool,
        legalBasisName: String?,
        legalBasisDescription: String?
    ) {
        self.init(
            code: purpose.code,
            consent: consent,
            required: purpose.isRequired,
            requiresDisplay: purpose.needsDisplay,
            title: purpose.name ?? String(),
            legalBasisName: legalBasisName,
            purposeDescription: purpose.description ?? String(),
            legalBasisDescription: legalBasisDescription,
            categories: purpose.categories?.map(Props.Category.init) ?? []
        )
    }
}

extension Props.Category {
    init(with category: KetchSDK.Configuration.Purpose.PurposeCategory) {
        self.init(
            name: category.name,
            retentionPeriod: category.retentionPeriod,
            externalTransfers: category.externalTransfers,
            description: category.description
        )
    }
}

extension Props.Vendor {
    init(
        with vendor: KetchSDK.Configuration.Vendor,
        consent: Bool
    ) {
        var policyUrl: URL?
        if let policy = vendor.policyUrl {
            policyUrl = URL(string: policy)
        }

        self.init(
            id: vendor.id,
            name: vendor.name,
            isAccepted: consent,
            purposes: vendor.purposes?.map(Props.VendorPurpose.init),
            specialPurposes: vendor.purposes?.map(Props.VendorPurpose.init),
            features: vendor.purposes?.map(Props.VendorPurpose.init),
            specialFeatures: vendor.purposes?.map(Props.VendorPurpose.init),
            policyUrl: policyUrl
        )
    }
}

extension Props.VendorPurpose {
    init(with vendorPurpose: KetchSDK.Configuration.Vendor.VendorPurpose) {
        self.init(name: vendorPurpose.name, legalBasis: vendorPurpose.legalBasis)
    }
}
