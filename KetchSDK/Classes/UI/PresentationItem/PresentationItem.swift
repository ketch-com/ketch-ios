//
//  PresentationItem.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

extension KetchUI {
    public struct PresentationItem: Identifiable {
        let itemType: ItemType
        let config: KetchSDK.Configuration
        let consent: KetchSDK.ConsentStatus

        public var id: String { String(describing: itemType) }

        enum ItemType {
            case banner(BannerItem)
            case modal(ModalItem)
            case jit
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

            struct PreferenceItem {
                let config: KetchSDK.Configuration.PreferenceExperience
                let actionHandler: (Action) -> Void

                enum Action {
                    case save(purposesConsent: KetchSDK.ConsentStatus)
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

        @ViewBuilder
        public var content: some View {
            switch itemType {
            case .banner(let bannerItem): banner(item: bannerItem)
            case .modal(let modalItem): modal(item: modalItem)
            case .jit: jit
            case .preference(let preferenceItem): preference(item: preferenceItem)
            }
        }

        func banner(item: ItemType.BannerItem) -> some View {
            let bannerBackgroundColor = Color(hex: config.theme?.bannerBackgroundColor ?? String())
            let bannerButtonColor = Color(hex: config.theme?.bannerButtonColor ?? String())
            let bannerSecondaryButtonColor = Color(hex: config.theme?.bannerSecondaryButtonColor ?? String())
            let bannerContentColor = Color(hex: config.theme?.bannerContentColor ?? String())

            var primaryButton: BannerView.Props.Button?

            if item.config.buttonText.isEmpty == false {
                primaryButton = .init(
                    text: item.config.buttonText,
                    textColor: bannerBackgroundColor,
                    borderColor: bannerButtonColor,
                    backgroundColor: bannerButtonColor,
                    action: .primary
                )
            }

            var secondaryButton: BannerView.Props.Button?

            if let secondaryButtonText = item.config.secondaryButtonText, secondaryButtonText.isEmpty == false {
                secondaryButton = .init(
                    text: secondaryButtonText,
                    textColor: bannerButtonColor,
                    borderColor: bannerButtonColor,
                    backgroundColor: bannerSecondaryButtonColor,
                    action: .secondary
                )
            }

            let bannerProps = BannerView.Props(
                title: item.config.title ?? String(),
                text: item.config.footerDescription,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton,
                theme: BannerView.Props.Theme(
                    contentColor: bannerContentColor,
                    backgroundColor: bannerBackgroundColor,
                    linkColor: bannerButtonColor,
                    borderRadius: config.theme?.buttonBorderRadius ?? 0
                ),
                actionHandler: { action in
                    switch action {
                    case .primary: item.actionHandler(.primary)
                    case .secondary: item.actionHandler(.secondary)
                    case .close: break
                    case .openUrl(let url): return child(with: url)
                    }

                    return nil
                }
            )

            return BannerView(props: bannerProps)
                .asResponsiveSheet(style: .bottomSheet(backgroundColor: bannerBackgroundColor))
        }

        func modal(item: ItemType.ModalItem) -> some View {
            let theme = Props.Modal.Theme(with: config.theme)

            let purposesProps = Props.PurposesList(
                modalConfig: item.config,
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

        private func handleAction(for item: ItemType.ModalItem) -> ((ModalView.Action) -> KetchUI.PresentationItem?) {
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

        var jit: some View {
            JitView()
                .asResponsiveSheet(style: .popUp)
        }

        func preference(item: ItemType.PreferenceItem) -> some View {
//            let theme = config.theme
//
//            let preferenceTheme = PreferenceView.Props.Theme(
//                contentColor: .white,
//                backgroundColor: .black,
//                linkColor: .red,
//                borderRadius: 5,
//                firstButtonTextColor: .white,
//                firstButtonBorderColor: .blue,
//                firstButtonBackgroundColor: .blue,
//                secondButtonTextColor: .blue,
//                secondButtonBorderColor: .blue,
//                secondButtonBackgroundColor: .white
//            )
//
////            let modalHeaderBackgroundColor = Color(hex: theme?.modalHeaderBackgroundColor ?? String())
////            let modalHeaderContentColor = Color(hex: theme?.modalHeaderContentColor ?? String())
////            let modalContentColor = Color(hex: theme?.modalContentColor ?? String())
////            let switchOffColor = Color(hex: theme?.modalSwitchOffColor ?? "#7C868D")
////            let switchOnColor = Color(hex: theme?.modalSwitchOnColor ?? theme?.modalContentColor ?? String())
////
////            let firstButtonBackgroundColor = Color(hex: theme?.modalButtonColor ?? String())
////            let firstButtonBorderColor = Color(hex: theme?.modalButtonColor ?? String())
////            let firstButtonTextColor = Color(hex: theme?.modalHeaderBackgroundColor ?? String())
////
////            let modalTheme = ModalView.Props.Theme(
////                headerBackgroundColor: modalHeaderBackgroundColor,
////                headerTextColor: modalHeaderContentColor,
////                bodyBackgroundColor: .white,
////                contentColor: modalContentColor,
////                linkColor: modalContentColor,
////                switchOffColor: switchOffColor,
////                switchOnColor: switchOnColor,
////                borderRadius: theme?.buttonBorderRadius ?? 0
////            )

//            let preferenceProps = Props.Preference(
//                title: item.config.title,
//                privacyPolicy: .init(
//                    tabName: item.config.overview.tabName,
//                    title: item.config.overview.bodyTitle,
//                    text: item.config.overview.bodyDescription
//                ),
//                preferences: .init(
//                    tabName: item.config.consents.tabName,
//                    purposes: PurposesView.Props(
//                        bodyTitle: item.config.consents.bodyTitle ?? "",
//                        bodyDescription: item.config.consents.bodyDescription ?? "",
//                        consentTitle: nil,
//                        purposes: [],
//                        vendors: [],
//                        theme: PurposesView.Props.Theme(
//                            bodyBackgroundColor: .white,
//                            contentColor: .black,
//                            linkColor: .red
//                        )
//                    )
//                ),
//                dataRights: .init(
//                    tabName: item.config.rights.tabName,
//                    title: item.config.rights.bodyTitle,
//                    text: item.config.rights.bodyDescription
//                ),
//                theme: preferenceTheme,
//                actionHandler: { action in
//                    switch action {
////                    case .save(let purposesConsent, let vendors):
////                        item.actionHandler(
////                            .save(
////                                purposesConsent: KetchSDK.ConsentStatus(
////                                    purposes: purposesConsent,
////                                    vendors: vendors
////                                )
////                            )
////                        )
//
//                    case .close: break
//                    case .openUrl(let url): return child(with: url)
//                    }
//
//                    return nil
//                }
//            )

            JitView()
                .asResponsiveSheet(style: .popUp)

//            return PreferenceView(props: preferenceProps, actionHandler: nil)
//                .asResponsiveSheet(style: .screenCover)
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
    }

    enum ViewStyle {
        case bottomSheet(backgroundColor: Color = Color(UIColor.systemBackground))
        case popUp
        case screenCover
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
