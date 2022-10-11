//
//  ketchSDK.swift
//  ketchSDK
//
//  Created by Anton Lyfar on 05.10.2022.
//

import Combine

public protocol KetchSDK_Protocol {
    func config()
}

public class KetchSDK: KetchSDK_Protocol {
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        
    }

    public func config() {
        KetchApiRequest
            .fetchConfig()
            .sink { error in
                print(error)
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func bootConfig() {
        KetchApiRequest
            .fetchBootConfig()
            .sink { error in
                print(error)
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func setConsent() {
        KetchApiRequest
            .updateConsent(
                update: ConsentUpdate(
                    organizationCode: "transcenda",
                    controllerCode: "my_controller",
                    propertyCode: "website_smart_tag",
                    environmentCode: "production",
                    identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                    collectedAt: nil,
                    jurisdictionCode: "default",
                    migrationOption: .migrateDefault,
                    purposes: [
                        "essential_services": PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "analytics": PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "behavioral_advertising": PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "email_marketing": PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "tcf.purpose_1": PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "consent_optin"),
                        "somepurpose_key": PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "consent_optin")
                    ],
                    vendors: nil
                )
            )
            .sink { error in
                print(error)
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func getConfig() {
        KetchApiRequest
            .getConsent(
                config: ConsentConfig(
                    organizationCode: "transcenda",
                    controllerCode: "my_controller",
                    propertyCode: "website_smart_tag",
                    environmentCode: "production",
                    jurisdictionCode: "default",
                    identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                    purposes: [
                        "essential_services": PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "analytics": PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "behavioral_advertising": PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "email_marketing": PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "tcf.purpose_1": PurposeLegalBasis(legalBasisCode: "consent_optin"),
                        "somepurpose_key": PurposeLegalBasis(legalBasisCode: "consent_optin")
                    ]
                )
            )
            .sink { error in
                print(error)
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }
}
