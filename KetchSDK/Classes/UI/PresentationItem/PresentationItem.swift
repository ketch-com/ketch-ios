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
        let actionHandler: (Action) -> Void

        public var id: String { String(describing: itemType) }

        enum ItemType {
            case banner(KetchSDK.Configuration.Experience.ConsentExperience.Banner)
            case modal(KetchSDK.Configuration.Experience.ConsentExperience.Modal)
            case jit
            case preference
        }

        enum Action {
            case primary
            case secondary
        }

        @ViewBuilder
        public var content: some View {
            switch itemType {
            case .banner(let _banner): banner(_banner)
            case .modal(let _modal): modal(_modal)
            case .jit: jit
            case .preference: preference
            }
        }

        func banner(_ banner: KetchSDK.Configuration.Experience.ConsentExperience.Banner) -> some View {
            let bannerBackgroundColor = Color(hex: config.theme?.bannerBackgroundColor ?? String())
            let bannerButtonColor = Color(hex: config.theme?.bannerButtonColor ?? String())
            let bannerSecondaryButtonColor = Color(hex: config.theme?.bannerSecondaryButtonColor ?? String())
            let bannerContentColor = Color(hex: config.theme?.bannerContentColor ?? String())

            var primaryButton: BannerView.Props.Button?

            if banner.buttonText.isEmpty == false {
                primaryButton = .init(
                    text: banner.buttonText,
                    textColor: bannerBackgroundColor,
                    borderColor: bannerButtonColor,
                    backgroundColor: bannerButtonColor,
                    action: .primary
                )
            }

            var secondaryButton: BannerView.Props.Button?

            if let secondaryButtonText = banner.secondaryButtonText, secondaryButtonText.isEmpty == false {
                secondaryButton = .init(
                    text: secondaryButtonText,
                    textColor: bannerButtonColor,
                    borderColor: bannerButtonColor,
                    backgroundColor: bannerSecondaryButtonColor,
                    action: .secondary
                )
            }

            let bannerProps = BannerView.Props(
                title: banner.title ?? String(),
                text: banner.footerDescription,
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
                    case .primary:
                        actionHandler(.primary)
                        return nil

                    case .secondary:
                        actionHandler(.secondary)
                        return nil

                    case .close: return nil
                    case .openUrl(let url): return child(with: url)
                    }
                }
            )

            return BannerView(props: bannerProps)
                .asResponsiveSheet(style: .bottomSheet(backgroundColor: bannerBackgroundColor))
        }

        func modal(_ modal: KetchSDK.Configuration.Experience.ConsentExperience.Modal) -> some View {
            let modalProps = ModalView.Props(
                title: "Privacy Center",
                bodyTitle: "About Your Privacy",
                bodyDescription:
                    """
                    Axonic, Inc. determines the use of personal data collected on our media properties and across \
                    the internet. We may collect data that you submit to us directly or data that we collect \
                    automatically including from cookies (such as device information or IP address).
                    """
                    ,
                purposes: [],
                vendors: [],
                categories: [],
                primaryButton: ModalView.Props.Button(
                    text: "I understand",
                    textColor: .white,
                    borderColor: .blue,
                    backgroundColor: .blue,
                    action: .save
                ),
                theme: ModalView.Props.Theme(
                    contentColor: .black,
                    backgroundColor: .white,
                    linkColor: .red,
                    borderRadius: 5
                ),
                actionHandler: { action in
                    nil
                }
            )

            return ModalView(props: modalProps)
                .asResponsiveSheet(style: .popUp)
        }

        var jit: some View {
            JitView()
                .asResponsiveSheet(style: .popUp)
        }

        var preference: some View {
            PreferenceView()
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

private extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64

    switch hex.count {
    case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default: (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
  }
}
