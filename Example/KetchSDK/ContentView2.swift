//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK
import AdSupport
import AppTrackingTransparency

class Content2ViewModel: ObservableObject {
    @Published var ketch: Ketch?
    @Published var ketchUI: KetchUI?
    @Published var authorizationDenied = false

    init() { }

    func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
            if case .authorized = authorizationStatus {
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier

                DispatchQueue.main.async {
                    self.setupKetch(advertisingIdentifier: advertisingId)
                }
            } else if case .denied = authorizationStatus {
                self.authorizationDenied = true
            }
        }
    }

    private func setupKetch(advertisingIdentifier: UUID) {
        let ketch = KetchSDK.create(
            organizationCode: "transcenda",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: [.idfa(advertisingIdentifier.uuidString)]
        )

        ketch.add(plugins: [TCF(), CCPA()])

        self.ketch = ketch
        ketchUI = KetchUI(ketch: ketch)
    }
}

struct ContentView2: View {
    @StateObject private var viewModel = Content2ViewModel()
    @State var showDialogsAutomatically = false
    @State var webPresentationItem: KetchUI.WebPresentationItem?
    
    var body: some View {
        VStack(spacing: 40) {
            Button("Configuration") { viewModel.ketch?.loadConfiguration() }
            
            if let ketchUI = viewModel.ketchUI {
                Button("Top Left")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .top, hpos: .left))
                    webPresentationItem = ketchUI.webPresentationItem
                }
                
                Button("Top Center")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .top, hpos: .center))
                    webPresentationItem = ketchUI.webPresentationItem
                }
                
                Button("Top Right")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .top, hpos: .right))
                    webPresentationItem = ketchUI.webPresentationItem
                }
                
                Button("Bottom Left")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .bottom, hpos: .left))
                    webPresentationItem = ketchUI.webPresentationItem
                }
                
                Button("Bottom Center")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .bottom, hpos: .center))
                    webPresentationItem = ketchUI.webPresentationItem
                }
                
                Button("Bottom Right")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .bottom, hpos: .right))
                    webPresentationItem = ketchUI.webPresentationItem
                }
                
                Button("Center")   {
                    ketchUI.showExperience(bannerConfig: .init(vpos: .center, hpos: .center))
                    webPresentationItem = ketchUI.webPresentationItem
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                //  Delay after SwiftUI view appearing is required for alert presenting, otherwise it will not be shown
                viewModel.requestTrackingAuthorization()
            }
        }
        .onChange(of: showDialogsAutomatically) { value in
            viewModel.ketchUI?.showDialogsIfNeeded = value
        }
        .alert(isPresented: $viewModel.authorizationDenied) {
            Alert(
                title: Text("Tracking Authorization Denied by app settings"),
                message: Text("Please allow tracking in Settings -> Privacy -> Tracking"),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(
                    Text("Edit preferences"),
                    action: {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            )
        }
        .ketchBanner(model: $webPresentationItem)
    }
}

struct KetchTestView2: View {
    enum Jurisdiction {
        static let GDPR = "gdpr"
        static let CCPA = "ccpa"
    }

    @StateObject var ketch: Ketch

    var body: some View {
        VStack(spacing: 40) {
            Button("Configuration")      { ketch.loadConfiguration() }
//            Button("Configuration GDPR") { ketch.loadConfiguration(jurisdiction: Jurisdiction.GDPR) }
//            Button("Configuration CCPA") { ketch.loadConfiguration(jurisdiction: Jurisdiction.CCPA) }

//            if let config = ketch.configuration {
//                Button("Invoke Rights")  { ketch.invokeRights(right: config.rights?.first, user: user) }
//                Button("Get Consent")    { ketch.loadConsent() }
//                Button("Update Consent") {
//                    let purposes = config.purposes?
//                        .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]()) { result, purpose in
//                            result[purpose.code] = .init(allowed: true, legalBasisCode: purpose.legalBasisCode)
//                        }
//
//                    let vendors = config.vendors?.map(\.id)
//
//                    ketch.updateConsent(purposes: purposes, vendors: vendors)
//                }
//            }
        }
    }

    private var user: KetchSDK.InvokeRightConfig.User {
        .init(
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
    }
}

struct KetchUITestView2: View {
    @StateObject var ketchUI: KetchUI

    var body: some View {
        VStack(spacing: 40) {
            if let config = ketchUI.configuration, ketchUI.consentStatus != nil {
                Button("Show Banner")           { ketchUI.showBanner() }
                Button("Show Modal")            { ketchUI.showModal() }
                Button("Show Preference")       { ketchUI.showPreference() }
                Button("Show JIT")              {
                    if let purpose = config.purposes?.first {
                        ketchUI.showJIT(purpose: purpose)
                    }
                }
            }
        }
        .fullScreenCover(item: $ketchUI.presentationItem, content: \.content)
//        .fullScreenCover(item: $ketchUI.webPresentationItem, content: \.content)
    }
}

struct BannerData: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
}

struct TestBannerModifier: View {
    @State var model: BannerData?
    var body: some View {
        VStack {
            Button("Test") { model = BannerData(title: "Error", message: "Fix It!")}
            Button("Reset") { model = nil }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .modifier(BannerModifier(model: $model))
//        .ketchBanner(model: $model)
    }
}

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

extension View {
    func ketchBanner(model: Binding<KetchUI.WebPresentationItem?>) -> some View {
        modifier(BannerModifier(model: model))
    }
}

struct BannerModifier: ViewModifier {
    @Binding var model: KetchUI.WebPresentationItem?
    
    @ViewBuilder
    var sample: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "exclamationmark.triangle.fill")
            VStack(alignment: .leading) {
                Text("Banner")
                    .font(.headline)
                Text("Message")
                    .font(.footnote)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.red)
        .cornerRadius(10)
        .shadow(radius: 10)
        Spacer()
    }
    
    private var transitionEdge: Edge {
        guard let bannerConfig = model?.bannerConfig else { return .bottom }
        
        switch (bannerConfig.hpos, bannerConfig.vpos) {
        case (.center, .top): return .top
        case (.center, .bottom): return .bottom
        case (.left, _): return .leading
        case (.right, _): return .trailing
        case (.center, .center): return .bottom
        }
    }
    
    private var paddingEdge: Edge.Set {
        guard let bannerConfig = model?.bannerConfig else { return .bottom }
        
        switch bannerConfig.vpos {
        case .top: return .bottom
        case .bottom: return .top
        case .center: return [.top, .bottom]
        }
    }
    
    private var paddingValue: CGFloat? {
        guard let bannerConfig = model?.bannerConfig else { return nil }
        
        switch bannerConfig.vpos {
        case .center: return 100
        default: return 200
        }
    }
    
    private var transition: AnyTransition {
        let isCenterAnimation = model?.bannerConfig?.hpos == .center && model?.bannerConfig?.vpos == .center
        
        return isCenterAnimation
        ? AnyTransition.scale(scale: 1).combined(with: .opacity)
        : AnyTransition.move(edge: transitionEdge).combined(with: .opacity)
    }
    
    @ViewBuilder
    var bannerView: some View {
        if let presentationItem = model {
            presentationItem.content
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding()
                .padding(paddingEdge, paddingValue)
                .transition(transition)
                .animation(.easeInOut)
        }
        
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { _ in }
                .overlay {
                    if model != nil {
                        Color.white.opacity(0.001)
                            .onTapGesture {
                                withAnimation { model = nil }
                            }
                        bannerView
                    }
                }
        }
    }
}

#Preview {
    TestBannerModifier()
}
