//
//  Props+DataRightsView.swift
//  KetchSDK
//

import SwiftUI

extension Props {
    struct DataRightsView {
        let bodyTitle: String?
        let bodyDescription: String?
        let theme: Theme
        let rights: [Right]

        struct Right: DataRightCoding, Hashable, RightDescription {
            let code: String
            let name: String
            let description: String
        }

        struct Theme {
            let titleFontSize: CGFloat = 16

            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color

            let borderRadius: Int

            let firstButtonBackgroundColor: Color
            let firstButtonBorderColor: Color
            let firstButtonTextColor: Color

            let secondButtonBackgroundColor: Color
            let secondButtonBorderColor: Color
            let secondButtonTextColor: Color
        }
    }
}

protocol DataRightCoding {
    var code: String { get }
    var name: String { get }
    var description: String { get }
}

extension DataRightCoding {
    var dataRightsProps: Props.DataRightsView.Right { .init(code: code, name: name, description: description ) }
}

extension KetchSDK.Configuration.Right: DataRightCoding {  }

extension DataRightCoding {
    var configRight: KetchSDK.Configuration.Right { .init(code: code, name: name, description: description ) }
}
