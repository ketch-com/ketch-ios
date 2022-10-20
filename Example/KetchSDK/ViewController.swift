//
//  ViewController.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10/05/2022.
//  Copyright (c) 2022 Anton Lyfar. All rights reserved.
//

import UIKit
import Combine
import KetchSDK

class ViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    func loadData() {
        KetchSDK
            .shared
            .config(
                organization: "transcenda",
                property: "website_smart_tag"
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

        KetchSDK
            .shared
            .fetchConfig(
                organization: "transcenda",
                property: "website_smart_tag"
            ) { result in
                switch result {
                case .failure(let error): break
                case .success(let config): break
                }
            }

        KetchSDK
            .shared
            .setConsent(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                collectedAt: nil,
                jurisdictionCode: "default",
                migrationOption: .migrateDefault,
                purposes: [
                    "essential_services": .init(allowed: true, legalBasisCode: "disclosure"),
                    "analytics": .init(allowed: true, legalBasisCode: "disclosure"),
                    "behavioral_advertising": .init(allowed: true, legalBasisCode: "disclosure"),
                    "email_marketing": .init(allowed: true, legalBasisCode: "disclosure"),
                    "tcf.purpose_1": .init(allowed: true, legalBasisCode: "consent_optin"),
                    "somepurpose_key": .init(allowed: true, legalBasisCode: "consent_optin")
                ],
                vendors: nil
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

        let update = KetchSDK.ConsentUpdate(
            organizationCode: "transcenda",
            controllerCode: "my_controller",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
            collectedAt: nil,
            jurisdictionCode: "default",
            migrationOption: .migrateDefault,
            purposes: [
                "essential_services": .init(allowed: true, legalBasisCode: "disclosure"),
                "analytics": .init(allowed: true, legalBasisCode: "disclosure"),
                "behavioral_advertising": .init(allowed: true, legalBasisCode: "disclosure"),
                "email_marketing": .init(allowed: true, legalBasisCode: "disclosure"),
                "tcf.purpose_1": .init(allowed: true, legalBasisCode: "consent_optin"),
                "somepurpose_key": .init(allowed: true, legalBasisCode: "consent_optin")
            ],
            vendors: nil
        )

        KetchSDK
            .shared
            .fetchSetConsent(consentUpdate: update) { result in
                switch result {
                case .failure(let error): break
                case .success(let config): break
                }
            }

        KetchSDK
            .shared
            .getConsent(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                jurisdictionCode: "default",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                purposes: [
                    "essential_services": .init(legalBasisCode: "disclosure"),
                    "analytics": .init(legalBasisCode: "disclosure"),
                    "behavioral_advertising": .init(legalBasisCode: "disclosure"),
                    "email_marketing": .init(legalBasisCode: "disclosure"),
                    "tcf.purpose_1": .init(legalBasisCode: "consent_optin"),
                    "somepurpose_key": .init(legalBasisCode: "consent_optin")
                ]
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

        let config = KetchSDK.ConsentConfig(
            organizationCode: "transcenda",
            controllerCode: "my_controller",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            jurisdictionCode: "default",
            identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
            purposes: [
                "essential_services": .init(legalBasisCode: "disclosure"),
                "analytics": .init(legalBasisCode: "disclosure"),
                "behavioral_advertising": .init(legalBasisCode: "disclosure"),
                "email_marketing": .init(legalBasisCode: "disclosure"),
                "tcf.purpose_1": .init(legalBasisCode: "consent_optin"),
                "somepurpose_key": .init(legalBasisCode: "consent_optin")
            ]
        )

        KetchSDK
            .shared
            .fetchGetConsent(
                consentConfig: config
            ) { result in
                switch result {
                case .failure(let error): break
                case .success: break
                }
            }

        KetchSDK
            .shared
            .invokeRights(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                invokedAt: nil,
                jurisdictionCode: "default",
                rightCode: "gdpr_portability",
                user: .init(
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
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)

        let rightsConfig = KetchSDK.InvokeRightConfig(
            organizationCode: "transcenda",
            controllerCode: "my_controller",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
            invokedAt: nil,
            jurisdictionCode: "default",
            rightCode: "gdpr_portability",
            user: .init(
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

        KetchSDK
            .shared
            .fetchInvokeRights(
                config: rightsConfig
            ) { result in
                switch result {
                case .failure(let error): break
                case .success: break
                }
            }
    }
}

