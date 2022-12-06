//
//  Props.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 06.12.2022.
//

import SwiftUI

enum Props { }

extension Props.Modal.Theme {
    init(with theme: KetchSDK.Configuration.Theme?) {
        let modalHeaderBackgroundColor = Color(hex: theme?.modalHeaderBackgroundColor ?? String())
        let modalHeaderContentColor = Color(hex: theme?.modalHeaderContentColor ?? String())
        let modalContentColor = Color(hex: theme?.modalContentColor ?? String())
        let switchOffColor = Color(hex: theme?.modalSwitchOffColor ?? "#7C868D")
        let switchOnColor = Color(hex: theme?.modalSwitchOnColor ?? theme?.modalContentColor ?? String())

        let firstButtonBackgroundColor = Color(hex: theme?.modalButtonColor ?? String())
        let firstButtonBorderColor = Color(hex: theme?.modalButtonColor ?? String())
        let firstButtonTextColor = Color(hex: theme?.modalHeaderBackgroundColor ?? String())

        self.init(
            headerBackgroundColor: modalHeaderBackgroundColor,
            headerTextColor: modalHeaderContentColor,
            bodyBackgroundColor: .white,
            contentColor: modalContentColor,
            linkColor: modalContentColor,
            switchOffColor: switchOffColor,
            switchOnColor: switchOnColor,
            borderRadius: theme?.buttonBorderRadius ?? 0,
            firstButtonBackgroundColor: firstButtonBackgroundColor,
            firstButtonBorderColor: firstButtonBorderColor,
            firstButtonTextColor: firstButtonTextColor
        )
    }
}

extension Props.PurposesList {
    init(
        modalConfig: KetchSDK.Configuration.Experience.ConsentExperience.Modal,
        purposes: [KetchSDK.Configuration.Purpose]?,
        vendors: [KetchSDK.Configuration.Vendor]?,
        purposesConsent: [String: Bool],
        vendorsConsent: [String]?,
        theme: Theme
    ) {
        let hideConsentTitle = modalConfig.hideConsentTitle ?? false
        let hideLegalBases = modalConfig.hideLegalBases ?? false
        let bodyTitle = modalConfig.bodyTitle ?? String()
        let bodyDescription = modalConfig.bodyDescription ?? String()
        let consentTitle = hideConsentTitle ? nil : modalConfig.consentTitle

        let purposes = purposes?.map { purpose in
            Props.Purpose(
                with: purpose,
                consent: purposesConsent[purpose.code] ?? false,
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
            consentTitle: consentTitle,
            purposes: purposes ?? [],
            vendors: vendors ?? [],
            theme: theme
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
            required: purpose.requiresOptIn ?? false,
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

extension Props.Modal.Theme {
    var purposesListTheme: Props.PurposesList.Theme {
        .init(
            bodyBackgroundColor: .white,
            contentColor: contentColor,
            linkColor: contentColor
        )
    }

    var firstButtonTheme: Props.Button.Theme {
        .init(
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }
}

extension Props.PurposesList.Theme {
    var vendorListTheme: Props.VendorList.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.PurposesList.Theme {
    var categoryListTheme: Props.CategoryList.Theme {
        .init(
            bodyBackgroundColor: bodyBackgroundColor,
            contentColor: contentColor,
            linkColor: linkColor
        )
    }
}

extension Props.Preference.Theme {
    var purposesListTheme: Props.PurposesList.Theme {
        .init(
            bodyBackgroundColor: .white,
            contentColor: contentColor,
            linkColor: contentColor
        )
    }

    var firstButtonTheme: Props.Button.Theme {
        .init(
            textColor: firstButtonBackgroundColor,
            borderColor: firstButtonBorderColor,
            backgroundColor: firstButtonTextColor
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
