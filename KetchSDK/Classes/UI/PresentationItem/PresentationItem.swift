//
//  PresentationItem.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

extension KetchUI {
    enum ViewStyle {
        case bottomSheet(backgroundColor: Color = Color(UIColor.systemBackground))
        case popUp
        case screenCover
    }

    public struct PresentationItem: Identifiable {
        let itemType: ItemType
        let config: KetchSDK.Configuration
        let consent: KetchSDK.ConsentStatus

        public var id: String { String(describing: itemType) }

        enum ItemType {
            case banner(BannerItem)
            case modal(ModalItem)
            case jit(JitItem)
            case preference(PreferenceItem)

            struct BannerItem {
                let config: KetchSDK.Configuration.Experience.ConsentExperience.Banner
                let actionHandler: (Action) -> Void

                enum Action {
                    case primary
                    case secondary
                }
            }

            struct ModalItem {
                let config: KetchSDK.Configuration.Experience.ConsentExperience.Modal
                let actionHandler: (Action) -> Void

                enum Action {
                    case save(purposesConsent: KetchSDK.ConsentStatus)
                }
            }

            struct JitItem {
                let config: KetchSDK.Configuration.Experience.ConsentExperience.JIT
                let actionHandler: (Action) -> Void

                enum Action {

                }
            }

            struct PreferenceItem {
                let config: KetchSDK.Configuration.PreferenceExperience
                let actionHandler: (Action) -> Void

                enum Action {
                    case save(purposesConsent: KetchSDK.ConsentStatus)
                    case request(right: DataRightCoding, user: UserDataCoding)
                }
            }
        }

        static func banner(
            bannerConfig: KetchSDK.Configuration.Experience.ConsentExperience.Banner,
            config: KetchSDK.Configuration,
            consent: KetchSDK.ConsentStatus,
            actionHandler: @escaping (ItemType.BannerItem.Action) -> Void
        ) -> PresentationItem {
            PresentationItem(
                itemType: .banner(
                    ItemType.BannerItem(
                        config: bannerConfig,
                        actionHandler: actionHandler
                    )
                ),
                config: config,
                consent: consent
            )
        }

        static func modal(
            modalConfig: KetchSDK.Configuration.Experience.ConsentExperience.Modal,
            config: KetchSDK.Configuration,
            consent: KetchSDK.ConsentStatus,
            actionHandler: @escaping (ItemType.ModalItem.Action) -> Void
        ) -> PresentationItem {
            PresentationItem(
                itemType: .modal(
                    ItemType.ModalItem(
                        config: modalConfig,
                        actionHandler: actionHandler
                    )
                ),
                config: config,
                consent: consent
            )
        }

        static func preference(
            preferenceConfig: KetchSDK.Configuration.PreferenceExperience,
            config: KetchSDK.Configuration,
            consent: KetchSDK.ConsentStatus,
            actionHandler: @escaping (ItemType.PreferenceItem.Action) -> Void
        ) -> PresentationItem {
            PresentationItem(
                itemType: .preference(
                    ItemType.PreferenceItem(
                        config: preferenceConfig,
                        actionHandler: actionHandler
                    )
                ),
                config: config,
                consent: consent
            )
        }

        static func jit(
            jitConfig: KetchSDK.Configuration.Experience.ConsentExperience.JIT,
            config: KetchSDK.Configuration,
            consent: KetchSDK.ConsentStatus,
            actionHandler: @escaping (ItemType.JitItem.Action) -> Void
        ) -> PresentationItem {
            PresentationItem(
                itemType: .jit(
                    ItemType.JitItem(
                        config: jitConfig,
                        actionHandler: actionHandler
                    )
                ),
                config: config,
                consent: consent
            )
        }

        @ViewBuilder
        public var content: some View {
            switch itemType {
            case .banner(let bannerItem): banner(item: bannerItem)
            case .modal(let modalItem): modal(item: modalItem)
            case .jit(let jitItem): jit(item: jitItem)
            case .preference(let preferenceItem): preference(item: preferenceItem)
            }
        }

        func banner(item: ItemType.BannerItem) -> some View {
            let theme = Props.Banner.Theme(with: config.theme)

            var primaryButton: Props.Button?
            var secondaryButton: Props.Button?

            if item.config.buttonText.isEmpty == false {
                primaryButton = .init(text: item.config.buttonText, theme: theme.primaryButtonTheme)
            }

            if
                let secondaryButtonText = item.config.secondaryButtonText,
                secondaryButtonText.isEmpty == false
            {
                secondaryButton = .init(text: secondaryButtonText, theme: theme.secondaryButtonTheme)
            }

            let bannerProps = Props.Banner(
                title: item.config.title ?? String(),
                text: item.config.footerDescription,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton,
                theme: theme
            )

            return BannerView(props: bannerProps, actionHandler: handleAction(for: item))
                .asResponsiveSheet(style: .bottomSheet(backgroundColor: theme.backgroundColor))
        }

        func modal(item: ItemType.ModalItem) -> some View {
            let theme = Props.Modal.Theme(with: config.theme)

            let hideConsentTitle = item.config.hideConsentTitle ?? false

            let purposesProps = Props.PurposesList(
                bodyTitle: item.config.bodyTitle ?? String(),
                bodyDescription: item.config.bodyDescription ?? String(),
                consentTitle: hideConsentTitle ? nil : item.config.consentTitle,
                hideConsentTitle: hideConsentTitle,
                hideLegalBases: item.config.hideLegalBases ?? false,
                purposes: config.purposes,
                vendors: config.vendors,
                purposesConsent: consent.purposes,
                vendorsConsent: consent.vendors,
                theme: theme.purposesListTheme
            )

            let buttonProps = Props.Button(
                text: item.config.buttonText,
                theme: theme.firstButtonTheme
            )

            let modalProps = Props.Modal(
                title: item.config.title,
                showCloseIcon: item.config.showCloseIcon ?? false,
                purposes: purposesProps,
                saveButton: buttonProps,
                theme: theme
            )

            return ModalView(props: modalProps, actionHandler: handleAction(for: item))
                .asResponsiveSheet(style: .popUp)
        }

        func jit(item: ItemType.JitItem) -> some View {
            let theme = Props.Jit.Theme(with: config.theme)

            let vendors = config.vendors?.map { vendor in
                Props.Vendor(
                    with: vendor,
                    consent: consent.vendors?.contains(vendor.id) ?? false
                )
            }

            let jitProps = Props.Jit(
                title: item.config.title,
                showCloseIcon: item.config.showCloseIcon ?? false,
                description: item.config.bodyDescription,
                purpose: nil,
                vendors: vendors,
                acceptButtonText: item.config.acceptButtonText,
                declineButtonText: item.config.declineButtonText,
                moreInfoText: item.config.moreInfoText,
                moreInfoDestination: {
                    guard let moreInfoDestination = item.config.moreInfoDestination else { return nil }
                    switch moreInfoDestination {
                    case .gotoModal: return Props.Destination.modal
                    case .gotoPreference: return Props.Destination.preference
                    case .rejectAll: return Props.Destination.rejectAll
                    }
                }(),
                theme: theme
            )

            return JitView(props: jitProps, actionHandler: handleAction(for: item))
                .asResponsiveSheet(style: .popUp)
        }

        func preference(item: ItemType.PreferenceItem) -> some View {
            let theme = Props.Preference.Theme(with: config.theme)

            let purposesProps = Props.PurposesList(
                bodyTitle: item.config.consents.bodyTitle ?? String(),
                bodyDescription: item.config.consents.bodyDescription ?? String(),
                consentTitle: "Purposes",
                purposes: config.purposes,
                vendors: config.vendors,
                purposesConsent: consent.purposes,
                vendorsConsent: consent.vendors,
                theme: theme.purposesListTheme
            )

            let preferenceProps = Props.Preference(
                title: item.config.title,
                overview: .init(
                    tabName: item.config.overview.tabName,
                    title: item.config.overview.bodyTitle,
                    text: item.config.overview.bodyDescription
                ),
                consents: .init(
                    tabName: item.config.consents.tabName,
                    buttonText: item.config.consents.buttonText,
                    purposes: purposesProps
                ),
                rights: .init(
                    tabName: item.config.rights.tabName,
                    title: item.config.rights.bodyTitle,
                    text: item.config.rights.bodyDescription,
                    buttonText: item.config.rights.buttonText,
                    rights: config.rights?.map(\.props) ?? []
                ),
                theme: theme
            )


            return PreferenceView(props: preferenceProps, actionHandler: handleAction(for: item))
                .asResponsiveSheet(style: .screenCover)
        }

        func child(with url: URL) -> PresentationItem? {
            switch url.absoluteString {
//            case "triggerModal", "privacyPolicy", "termsOfService":
//                return .init(
//                    itemType: .modal(),
//                    config: config,
//                    consent: consent
//                ) { _ in }
                
            default:
                UIApplication.shared.open(url)
                return nil
            }
        }

// MARK: - Actions processing -
        private func handleAction(
            for item: ItemType.BannerItem
        ) -> ((BannerView.Action) -> KetchUI.PresentationItem?) {
            { action in
                switch action {
                case .primary: item.actionHandler(.primary)
                case .secondary: item.actionHandler(.secondary)
                case .close: break
                case .openUrl(let url): return child(with: url)
                }

                return nil
            }
        }

        private func handleAction(
            for item: ItemType.ModalItem
        ) -> ((ModalView.Action) -> KetchUI.PresentationItem?) {
            { action in
                switch action {
                case .save(let purposesConsent, let vendors):
                    item.actionHandler(
                        .save(
                            purposesConsent: KetchSDK.ConsentStatus(
                                purposes: purposesConsent,
                                vendors: vendors
                            )
                        )
                    )

                case .close: break
                case .openUrl(let url): return child(with: url)
                }

                return nil
            }
        }

        private func handleAction(
            for item: ItemType.JitItem
        ) -> ((JitView.Action) -> KetchUI.PresentationItem?) {
            { action in
                switch action {
                case .close: break
                case .openUrl(let url): return child(with: url)
                }

                return nil
            }
        }

        private func handleAction(
            for item: ItemType.PreferenceItem
        ) -> ((PreferenceView.Action) -> KetchUI.PresentationItem?) {
            { action in
                switch action {
                case .save(let purposesConsent, let vendors):
                    item.actionHandler(
                        .save(
                            purposesConsent: KetchSDK.ConsentStatus(
                                purposes: purposesConsent,
                                vendors: vendors
                            )
                        )
                    )

                case .close: break
                case .openUrl(let url): return child(with: url)
                case .request(let right, let user): item.actionHandler(.request(right: right, user: user))
                }

                return nil
            }
        }
    }
}

fileprivate struct ResponsiveSheetWrapper: ViewModifier {
    let style: KetchUI.ViewStyle

    init(style: KetchUI.ViewStyle) {
        self.style = style
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    func body(content: Content) -> some View {
        switch style {
        case .bottomSheet:
            ZStack (alignment: .bottom){
                Color(UIColor.systemBackground.withAlphaComponent(0.01))
                    .onTapGesture { presentationMode.wrappedValue.dismiss() }
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    // thumb
                    content
                }
                .asResponsiveSheetContent(style: style)
            }
            .clearSheetSystemBackground()
            .edgesIgnoringSafeArea(.bottom)

        case .popUp:
            ZStack  {
                Color(UIColor.systemBackground.withAlphaComponent(0.01))
                    .onTapGesture { presentationMode.wrappedValue.dismiss() }
                content
                    .asResponsiveSheetContent(style: style)
            }
            .padding()
            .clearSheetSystemBackground()

        case .screenCover:
            ZStack  {
                Color(UIColor.systemBackground.withAlphaComponent(0.01))
                    .onTapGesture { presentationMode.wrappedValue.dismiss() }
                content
                    .asResponsiveSheetContent(style: style)
            }
            .clearSheetSystemBackground()
            .edgesIgnoringSafeArea(.all)
        }
    }

    var thumb: some View {
        HStack{
            Spacer()
            Capsule()
                .frame(width: 40, height: 4)
                .foregroundColor(Color(UIColor.systemFill))
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

fileprivate struct ResponsiveSheetContent: ViewModifier {
    let style: KetchUI.ViewStyle

    init(style: KetchUI.ViewStyle) {
        self.style = style
    }

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    func body(content: Content) -> some View {
        switch style {
        case .bottomSheet(let color):
            content
                .padding(.bottom, safeAreaInsets.bottom)
                .background(
                    color
                        .cornerRadius(8, corners: [.topLeft, .topRight])
                        .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
                )

        case .popUp:
            content
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    Color(UIColor.systemBackground)
                        .cornerRadius(8, corners: [.allCorners])
                        .shadow(color: .black.opacity(0.35), radius: 20)
                )

        case .screenCover:
            content
                .padding(.leading, safeAreaInsets.leading)
                .padding(.trailing, safeAreaInsets.trailing)
                .padding(.top, safeAreaInsets.top)
                .padding(.bottom, safeAreaInsets.bottom)
                .background(
                    Color(UIColor.systemBackground)
                )
        }
    }
}

fileprivate struct ClearBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ClearBackgroundView())
    }
}

fileprivate struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

//MARK: - UIViewRepresentable
fileprivate struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

//MARK: - View Extension
extension View {
    func asResponsiveSheet(style: KetchUI.ViewStyle) -> some View {
        modifier(ResponsiveSheetWrapper(style: style))
    }

    fileprivate func asResponsiveSheetContent(style: KetchUI.ViewStyle) -> some View {
        modifier(ResponsiveSheetContent(style: style))
    }

    fileprivate func clearSheetSystemBackground() -> some View {
        modifier(ClearBackgroundViewModifier())
    }

    fileprivate func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        modifier(CornerRadiusStyle(radius: radius, corners: corners))
    }
}

//MARK: - EnvironmentKey & Values
fileprivate struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

fileprivate extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

//MARK: - UIEdgeInsets Extension
fileprivate extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
