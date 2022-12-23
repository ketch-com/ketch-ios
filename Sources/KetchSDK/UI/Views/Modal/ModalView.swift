//
//  ModalView.swift
//  KetchSDK
//

import SwiftUI

struct ModalView: View {
    enum Action {
        case save(purposeCodeConsents: [String: Bool], vendors: [String])
        case close
        case openUrl(URL)
    }

    let props: Props.Modal
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @ObservedObject private var consents = UserConsents()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Modal, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        consents = props.purposes.generateConsents()
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(props.title)
                        .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                        .foregroundColor(props.theme.headerTextColor)
                    if props.showCloseIcon {
                        Spacer()
                        Button {
                            handle(action: .close)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .foregroundColor(props.theme.headerTextColor)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                .background(props.theme.headerBackgroundColor)

                NavigationView {
                    VStack {
                        PurposesView(
                            props: props.purposes,
                            purposeConsents: $consents.purposeConsents,
                            vendorConsents: $consents.vendorConsents
                        ) {

                        } actionHandler: { action in
                            switch action {
                            case .close: handle(action: .close)
                            case .openUrl(let url): handle(action: .openUrl(url))
                            }
                        }

                        VStack(spacing: 24) {
                            if let saveButton = props.saveButton {
                                CustomButton(props: saveButton) {
                                    handle(
                                        action: .save(
                                            purposeCodeConsents: consents.purposeConsents.reduce(
                                                into: [String: Bool]()
                                            ) { result, purposeConsent in
                                                result[purposeConsent.purpose.code] = purposeConsent.consent
                                            },
                                            vendors: consents.vendorConsents
                                                .filter(\.isAccepted)
                                                .map(\.id)
                                        )
                                    )
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }

                            HStack {
                                LogoSection()
                                    .foregroundColor(props.theme.headerTextColor)
                                Spacer()
                            }
                        }
                        .padding(24)
                        .background(props.theme.headerBackgroundColor)
                    }
                }
                .accentColor(props.theme.contentColor)
            }
        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}
