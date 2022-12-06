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
        let purposes: PurposesView.Props
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
            let categories: [CategoriesView.Props.Category]
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
