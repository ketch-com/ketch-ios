//
//  ModalView+Props.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

extension ModalView {
    struct Props {
        let title: String
        let showCloseIcon: Bool
        let bodyTitle: String
        let bodyDescription: String
        let consentTitle: String?
        let purposes: [Purpose]
        
        let vendors: [Vendor]
        
        let saveButton: Button?
        
        let theme: Theme
        let actionHandler: (Action) -> KetchUI.PresentationItem?
        
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
        
        struct Vendor: Hashable, Identifiable {
            let id: String
            let name: String
            let isAccepted: Bool
            let purposes: [VendorPurpose]?
            let specialPurposes: [VendorPurpose]?
            let features: [VendorPurpose]?
            let specialFeatures: [VendorPurpose]?
            let policyUrl: URL?

            struct VendorPurpose: Hashable, Identifiable {
                var id: String { name }

                let name: String
                let legalBasis: String?
            }
        }
        
        struct Category: Hashable, Identifiable {
            var id: String { name }

            let name: String
            let retentionPeriod: String
            let externalTransfers: String
            let description: String
        }
        
        struct Button {
            let fontSize: CGFloat = 14
            let height: CGFloat = 44
            let borderWidth: CGFloat = 1
            
            let text: String
            let textColor: Color
            let borderColor: Color
            let backgroundColor: Color
        }
        
        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14
            
            let headerBackgroundColor: Color
            let headerTextColor: Color
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
            let switchOffColor: Color
            let switchOnColor: Color
            
            let borderRadius: Int
        }
        
        enum Action {
            case save(purposeCodeConsents: [String: Bool], vendors: [String])
            case close
            case openUrl(URL)
        }
    }
}
