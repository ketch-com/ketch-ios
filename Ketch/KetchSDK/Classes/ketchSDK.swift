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
        KetchApiRequest()
            .fetchConfig()
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func bootConfig() {
        KetchApiRequest()
            .fetchBootConfig()
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func setConsent() {
        KetchApiRequest()
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
                        "essential_services": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "analytics": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "behavioral_advertising": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "email_marketing": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                        "tcf.purpose_1": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "consent_optin"),
                        "somepurpose_key": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "consent_optin")
                    ],
                    vendors: nil
                )
            )
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func getConsent() {
        KetchApiRequest()
            .getConsent(
                config: ConsentConfig(
                    organizationCode: "transcenda",
                    controllerCode: "my_controller",
                    propertyCode: "website_smart_tag",
                    environmentCode: "production",
                    jurisdictionCode: "default",
                    identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                    purposes: [
                        "essential_services": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "analytics": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "behavioral_advertising": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "email_marketing": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                        "tcf.purpose_1": ConsentConfig.PurposeLegalBasis(legalBasisCode: "consent_optin"),
                        "somepurpose_key": ConsentConfig.PurposeLegalBasis(legalBasisCode: "consent_optin")
                    ]
                )
            )
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }

    public func invokeRights() {
        KetchApiRequest()
            .invokeRights(
                config: InvokeRightConfig(
                    organizationCode: "transcenda",
                    controllerCode: "my_controller",
                    propertyCode: "website_smart_tag",
                    environmentCode: "production",
                    identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                    invokedAt: nil,
                    jurisdictionCode: "default",
                    rightCode: "gdpr_portability",
                    user: InvokeRightConfig.User(
                        email: "user@email.com",
                        first: "FirstName",
                        last: "LastName",
                        country: nil,
                        stateRegion: nil,
                        description: nil,
                        phone: nil,
                        postalCode: nil,
                        addressLine1: nil,
                        addressLine2: nil
                    )
                )
            )
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }
}
