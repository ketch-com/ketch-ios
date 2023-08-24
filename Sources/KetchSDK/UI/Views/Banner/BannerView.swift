//
//  BannerView.swift
//  KetchSDK
//

import SwiftUI

struct BannerView: View {
    enum Action {
        case primary
        case secondary
        case close
        case openUrl(URL)
    }

    let props: Props.Banner
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(props.title)
                    .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                    .foregroundColor(props.theme.contentColor)
                Spacer()
                Button(action: {
                    handle(action: .close)
                }) {
                    Image(systemName: "xmark")
                }
                .foregroundColor(props.theme.contentColor)
            }
            
            TitleDescriptionSection(
                props: props.titleDescriptionSectionProps
            ) { action in
                switch action {
                case .openUrl(let url): handle(action: .openUrl(url))
                }
            }
            .padding(.bottom, 12)
            
            
            if let primaryButton = props.primaryButton {
                CustomButton(props: primaryButton) {
                    self.handle(action: .primary)
                }
            }
            
            if let secondaryButton = props.secondaryButton {
                CustomButton(props: secondaryButton) {
                    self.handle(action: .secondary)
                }
            }
            if (props.theme.showWatermark) {
                HStack {
                    LogoSection(textContent: props.localizedStrings?.poweredBy ?? "Powered By")
                        .foregroundColor(props.theme.contentColor)
                    Spacer()
                }
            }
        }
        .padding(24)
        .background(props.theme.backgroundColor)
        .fullScreenCover(item: $presentationItem, onDismiss: {
                presentationMode.wrappedValue.dismiss()
        }) { item in
            item.content
        }
    }

    private func handle(action: Action) {
        let item = actionHandler(action)
        if item == nil {
            presentationMode.wrappedValue.dismiss()
        }
        presentationItem = item
    }
}
