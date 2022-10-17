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
    private var ketch = KetchSDK()
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        ketch
            .config()
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)

        ketch
            .bootConfig()
            .sink { completion in
                switch completion {
                case .failure(let error): print(error)
                case .finished: break
                }
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)

        ketch
            .setConsent(
                consentUpdate: .init(
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

        ketch
            .getConsent(
                consentConfig: .init(
                    organizationCode: "transcenda",
                    controllerCode: "my_controller",
                    propertyCode: "website_smart_tag",
                    environmentCode: "production",
                    jurisdictionCode: "default",
                    identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                    purposes: [
                        "essential_services": .init(allowed: true, legalBasisCode: "disclosure"),
                        "analytics": .init(allowed: true, legalBasisCode: "disclosure"),
                        "behavioral_advertising": .init(allowed: true, legalBasisCode: "disclosure"),
                        "email_marketing": .init(allowed: true, legalBasisCode: "disclosure"),
                        "tcf.purpose_1": .init(allowed: true, legalBasisCode: "consent_optin"),
                        "somepurpose_key": .init(allowed: true, legalBasisCode: "consent_optin")
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

        ketch
            .invokeRights(
                config: KetchSDK.InvokeRightConfig(
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

