//
//  Props+PurposeList.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
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
