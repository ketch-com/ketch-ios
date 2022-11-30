//
//  ModalView+UserConsentsList.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

extension ModalView {
    struct UserConsent: Hashable, Identifiable {
        var id: String { purpose.id }

        var consent: Bool
        let required: Bool
        let purpose: Props.Purpose
    }

    class UserConsentsList: ObservableObject {
        @Published var userConsents: [UserConsent]

        init(userConsents: [UserConsent]) {
            self.userConsents = userConsents
        }
    }
}
