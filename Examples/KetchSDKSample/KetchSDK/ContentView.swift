//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK
import Combine
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif


import Foundation

/// Flip `enabled` to redirect UAT tag script URLs to local dev servers.
enum DevUrlOverrides {
    static let enabled = true

    private static let localKetchSdk: [String: String] = [
        "https://cdn.uat.ketchjs.com/ketchtag/stable/v2.12/ketch-sdk.js": "http://localhost:9000/ketch-sdk.js",
        "ketch-sdk.js": "http://localhost:9000/ketch-sdk.js",
    ]

    static let forSimulator = localKetchSdk
    static let forDevice = localKetchSdk
}


//
//  SampleDashboardState.swift
//  KetchSDK
//

import Foundation
import SwiftUI

@MainActor
final class SampleDashboardState: ObservableObject {
    @Published var initState = "Initialized"
    @Published var statusText = "Ketch initialized"
    @Published var loadState = "idle"
    @Published var experienceVisibility = "hidden"
    @Published var dismissReason = "—"
    @Published var webViewVisible = "unknown"

    @Published var environment = "Not set"
    @Published var jurisdiction = "Not set"
    @Published var region = "Not set"
    @Published var consent = "Not set"
    @Published var ccpa = "Not set"
    @Published var tcf = "Not set"
    @Published var gpp = "Not set"

    @Published var attStatus = "N/A"
    @Published var ketchAtt = "—"
    @Published var ketchAttPrev = "—"

    @Published var headlessLocationResult = "—"
    @Published var headlessBootstrapResult = "—"
    @Published var headlessConsentResult = "—"

    @Published var eventLog: [String] = []

    func appendLog(_ message: String) {
        let line = "[\(Self.timestamp())] \(message)"
        eventLog.append(line)
        if eventLog.count > 50 {
            eventLog.removeFirst(eventLog.count - 50)
        }
    }

    func setStatus(_ text: String) {
        statusText = text
        appendLog(text)
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}


struct ContentView: View {
    @StateObject var dashboard = SampleDashboardState()
    @StateObject var ketchUI: KetchUI
    @State private var listener = SampleEventListener()
    @State var headlessCancellables = Set<AnyCancellable>()

    init() {
        let ketch = KetchSDK.create(
            organizationCode: "ethansch061226",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            identities: [
                Ketch.Identity(key: "email", value: "sample-test@integration.ketch.test")
            ]
        )

        let ketchUI = KetchUI(ketch: ketch, experienceOptions: [.logLevel(.trace)])
        _ketchUI = StateObject(wrappedValue: ketchUI)
    }

    @State private var selectedTabs: Set<KetchUI.ExperienceOption.PreferencesTab> = Set([.overviewTab, .consentsTab, .subscriptionsTab, .rightsTab])
    @State private var selectedTab = KetchUI.ExperienceOption.PreferencesTab.overviewTab
    @State var apiRegion = APIRegion.uat
    @State var org = "ethansch061226"
    @State var property = "website_smart_tag"
    @State var env = "production"
    @State private var lang = "en"
    @State private var jurisdiction = ""
    @State private var region = ""
    @State private var idName = ""
    @State private var idValue = ""
    @State private var identities = [Ketch.Identity]()
    @State private var age = ""

    var body: some View {
        ScrollView {
        VStack(alignment: .leading) {
            healthDashboard

            Text("Global options")
                .font(.title2)
            Text("Options that apply to both experiences")
                .font(.footnote)
                .foregroundStyle(Color.gray)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ]) {
                
                text("Organization", value: $org)
                text("Property", value: $property)
                text("Environment", value: $env)
                
                text("Language", value: $lang)
                text("Jurisdiction", value: $jurisdiction)
                text("Region", value: $region)
                
                text("Identities", value: $idName, prompt: "Name")
                text(" ", value: $idValue, prompt: "Value")
                
                VStack {
                    Spacer()
                        .frame(height: 18)
                    
                    HStack(alignment: .center) {
                        Button("Reset") {
                            identities.removeAll()
                        }
                        .padding(.leading, 4)
                        .disabled(identities.isEmpty)
                        
                        Spacer()
                        
                        Button("Add") {
                            guard !idName.isEmpty, !idValue.isEmpty else {
                                return
                            }
                            
                            identities.append(Ketch.Identity(key: idName, value: idValue))
                            idName = ""
                            idValue = ""
                        }
                        .padding(.trailing, 4)
                        .disabled(idName.isEmpty || idValue.isEmpty)
                    }
                }
                
                ageField
                
                Color.clear.frame(height: 0)
                Color.clear.frame(height: 0)
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            Text("API Region")
                .font(.subheadline)
            
            HStack {
                apiButton(api: .us)
                apiButton(api: .eu)
                apiButton(api: .uat)
            }
            .padding(.bottom, 16)
            
            Text("Preference Options")
                .font(.title2)
            
            Text("Options that only apply to the preference experience")
                .font(.footnote)
                .foregroundStyle(Color.gray)
                .padding(.bottom, 8)
            
            Text("Allowed Tabs")
                .font(.subheadline)
            HStack {
                checkbox(tab: .overviewTab, title: "Overview")
                checkbox(tab: .consentsTab, title: "Consent")
                checkbox(tab: .subscriptionsTab, title: "Subscriptions")
                checkbox(tab: .rightsTab, title: "Rights")
            }
            .padding(.bottom, 8)
            
            
            Text("Initial Tabs")
                .font(.subheadline)
            HStack {
                tabButton(tab: .overviewTab, title: "Overview")
                tabButton(tab: .consentsTab, title: "Consent")
                tabButton(tab: .subscriptionsTab, title: "Subscriptions")
                tabButton(tab: .rightsTab, title: "Rights")
            }
            .padding(.bottom, 16)
            
            Text("Actions")
                .font(.title2)
            
            Text("Trigger some SDK funcionality")
                .font(.footnote)
                .foregroundStyle(Color.gray)
            
            HStack {
                Button("Load") {
                    dashboard.loadState = "loading"
                    dashboard.setStatus("Load called")
                    ketchUI.reload(with: makeParameters)
                }

                Spacer()

                Button("Reload") {
                    ketchUI.reload(with: makeParameters)
                }
                
                Spacer()
                
                Button("Consent") {
                    showConsent()
                }
                
                Spacer()
                
                Button("Preferences") {
                    showPreferences()
                }
                
                Spacer()
                
                Button("Privacy Strings") {
                    showPrivacyStrings()
                }
                
                Spacer()
                
                Button("Apply CSS") {
                    applyCSS()
                }
            }
            .padding(.vertical)
            
        }
        .padding()
        }
        .background(.white)
        .ketchView(model: $ketchUI.webPresentationItem)
        .onAppear {
            listener.dashboard = dashboard
            ketchUI.eventListener = listener
            refreshATTStatus()
        }
    }

    func refreshATTStatus(logEvent: Bool = false) {
        if #available(iOS 14, *) {
            let status = KetchSDK.trackingAuthorizationStatusString()
            let prev = SampleLogging.storedAttPrev()
            dashboard.attStatus = status
            dashboard.ketchAtt = status
            dashboard.ketchAttPrev = prev
            if logEvent {
                let message = SampleLogging.formatAttState(current: status, previous: prev)
                dashboard.appendLog("ATT: \(message)")
                print("[KetchSample] ATT: \(message)")
            }
        }
    }

    func requestATT() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    self.refreshATTStatus(logEvent: true)
                    self.ketchUI.reload(with: self.makeParameters)
                }
            }
        }
    }
    
    var makeParameters: [KetchUI.ExperienceOption] {
        var parameters = [KetchUI.ExperienceOption]()
        if !org.isEmpty {
            parameters.append(.organizationCode(org))
        }
        
        if !property.isEmpty {
            parameters.append(.propertyCode(property))
        }
        
        if !env.isEmpty {
            parameters.append(.environment(env))
        }
        
        if !lang.isEmpty {
            parameters.append(.language(code: lang))
        }
        
        if !jurisdiction.isEmpty {
            parameters.append(.jurisdiction(code: jurisdiction))
        }
        
        if !region.isEmpty {
            parameters.append(.region(code: region))
        }
        
        parameters.append(.ketchURL(apiRegion.urlString))
        
        identities.forEach { identity in
            parameters.append(.identity(identity))
        }
        
        if let ageValue = UInt(age) {
            parameters.append(.age(ageValue))
        }

        if DevUrlOverrides.enabled {
            parameters.append(.webResourceUrlOverrides(DevUrlOverrides.forSimulator))
        }
        
        return parameters
    }
    
    private func showConsent() {
        var parameters = makeParameters
        parameters.append(.forceExperience(.consent))
        ketchUI.reload(with: parameters)
    }
    
    private func showPreferences() {
        var parameters = makeParameters
        
        if !selectedTabs.isEmpty {
            let selectedTabsNames = selectedTabs.compactMap { $0.rawValue }
            parameters.append(.preferencesTabs(selectedTabsNames.joined(separator: ",")))
            
            if selectedTabs.contains(selectedTab) {
                parameters.append(.preferencesTab(selectedTab))
            }
        }
        
        parameters.append(.forceExperience(.preferences))
        ketchUI.reload(with: parameters)
    }
    
    private func showPrivacyStrings() {
        // for some reson preview is not working when this strings are all in one array
        let keys = ["IABTCF_CmpSdkID",
                    "IABTCF_CmpSdkVersion",
                    "IABTCF_PolicyVersion",
                    "IABTCF_gdprApplies",
                    "IABTCF_PublisherCC",
                    "IABTCF_PurposeOneTreatment",
                    "IABTCF_UseNonStandardTexts",
                    "IABTCF_TCString",
                    "IABTCF_VendorConsents"]
        
        let keys2 = ["IABTCF_VendorLegitimateInterests",
                     "IABTCF_PurposeConsents",
                     "IABTCF_PurposeLegitimateInterests",
                     "IABTCF_SpecialFeaturesOptIns",
                     "IABTCF_PublisherConsent",
                     "IABTCF_PublisherLegitimateInterests",
                     "IABTCF_PublisherCustomPurposesConsents",
                     "IABTCF_PublisherCustomPurposesLegitimateInterests",
                     "IABUSPrivacy_String"]
        
        let keys3 = ["IABGPP_HDR_Version",
                     "IABGPP_HDR_Sections",
                     "IABGPP_HDR_GppString",
                     "IABGPP_GppSID",
                     "IABGPP_tcfeuv2_GppSID"]
        
        var summary = [String]()
        (keys + keys2 + keys3).forEach {
            let value = UserDefaults.standard.value(forKey: $0) ?? ""
            summary.append("\($0): \(value)")
        }
        dashboard.tcf = UserDefaults.standard.string(forKey: "IABTCF_TCString") ?? dashboard.tcf
        dashboard.ccpa = UserDefaults.standard.string(forKey: "IABUSPrivacy_String") ?? dashboard.ccpa
        dashboard.gpp = UserDefaults.standard.string(forKey: "IABGPP_HDR_GppString") ?? dashboard.gpp
        dashboard.setStatus("Privacy strings read (\(summary.count) keys)")
    }
    
    private func applyCSS() {
        var parameters = makeParameters
        parameters.append(.css("#ketch-banner-button-primary { display: none !important; }"))
        parameters.append(.forceExperience(.consent))
        ketchUI.reload(with: parameters)
    }
}

// MARK: - UI

fileprivate extension ContentView {
    func text(_ text: String, value: Binding<String>, prompt: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.subheadline)
            
            TextField("", text: value, prompt: prompt == nil ? nil : Text(prompt!))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(4)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color.gray)
                }
        }
    }
    
    var ageField: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Age")
                .font(.subheadline)
            
            TextField("", text: $age, prompt: Text("e.g. 18"))
                .keyboardType(.numberPad)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(4)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color.gray)
                }
                .onChange(of: age) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        age = filtered
                    }
                }
                .onSubmit {
                    ketchUI.reload(with: makeParameters)
                }
        }
    }
    
    func checkbox(tab: KetchUI.ExperienceOption.PreferencesTab, title: String) -> some View {
        HStack(spacing: 4) {
            Button {
                if selectedTabs.contains(tab) {
                    selectedTabs.remove(tab)
                } else {
                    selectedTabs.insert(tab)
                }
            } label: {
                Image(systemName: selectedTabs.contains(tab) ? "checkmark.square.fill" : "square")
            }
            .tint(.black)
            
            Text(title)
                .font(.footnote)
        }
    }
    
    func tabButton(tab: KetchUI.ExperienceOption.PreferencesTab, title: String) -> some View {
        HStack(spacing: 4) {
            Button {
                selectedTab = tab
            } label: {
                Image(systemName: selectedTab == tab ? "circle.fill" : "circle")
            }
            .tint(.black)
            
            Text(title)
                .font(.footnote)
        }
    }
    
    func apiButton(api: APIRegion) -> some View {
        HStack(spacing: 4) {
            Button {
                apiRegion = api
            } label: {
                Image(systemName: apiRegion == api ? "circle.fill" : "circle")
            }
            .tint(.black)
            
            Text(api.name)
                .font(.footnote)
        }
    }
}

//
//  ContentView+Dashboard.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK
import Combine
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

extension ContentView {
    @ViewBuilder
    var healthDashboard: some View {
        Text("SDK Health Dashboard")
            .font(.title2)
            .padding(.bottom, 4)

        dashboardSection("Connection") {
            dashboardRow("Init", dashboard.initState)
            dashboardRow("Status", dashboard.statusText)
            dashboardRow("Org / Property / Env", "\(effectiveOrg) / \(effectiveProperty) / \(effectiveEnvironment)")
            dashboardRow("API Region", apiRegion.name)
        }

        dashboardSection("WebView / Experience") {
            dashboardRow("Load", dashboard.loadState)
            dashboardRow("Visibility", dashboard.experienceVisibility)
            dashboardRow("Dismiss", dashboard.dismissReason)
            dashboardRow("WebView", dashboard.webViewVisible)
            #if canImport(AppTrackingTransparency)
            if #available(iOS 14, *) {
                dashboardRow("ketch_att", dashboard.ketchAtt)
                dashboardRow("ketch_att_prev", dashboard.ketchAttPrev)
            }
            #endif
        }

        dashboardSection("ATT (iOS)") {
            #if canImport(AppTrackingTransparency)
            if #available(iOS 14, *) {
                dashboardRow("Native ATT", dashboard.attStatus)
                HStack {
                    Button("Request ATT") { requestATT() }
                    Button("Reload WebView") {
                        refreshATTStatus(logEvent: true)
                        ketchUI.reload(with: makeParameters)
                    }
                }
            } else {
                Text("ATT requires iOS 14+")
                    .font(.footnote)
            }
            #else
            Text("ATT not available on this platform")
                .font(.footnote)
            #endif
        }

        dashboardSection("Privacy / Consent") {
            dashboardRow("Environment", dashboard.environment)
            dashboardRow("Jurisdiction", dashboard.jurisdiction)
            dashboardRow("Region", dashboard.region)
            dashboardRow("Consent", dashboard.consent)
            dashboardRow("US Privacy", dashboard.ccpa)
            dashboardRow("TCF", dashboard.tcf)
            dashboardRow("GPP", dashboard.gpp)
        }

        dashboardSection("Headless (live CDN)") {
            dashboardRow("Location", dashboard.headlessLocationResult)
            dashboardRow("Bootstrap", dashboard.headlessBootstrapResult)
            dashboardRow("Consent", dashboard.headlessConsentResult)
            HStack {
                Button("Fetch Location") { runHeadlessLocation() }
                Button("Fetch Bootstrap") { runHeadlessBootstrap() }
                Button("Cold Start") { runHeadlessConsent() }
            }
            .font(.footnote)
        }

        dashboardSection("Event Log") {
            if dashboard.eventLog.isEmpty {
                Text("Waiting for events...")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.gray)
            } else {
                ForEach(Array(dashboard.eventLog.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.footnote.monospaced())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.bottom, 16)
    }

    @ViewBuilder
    func dashboardSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(.bottom, 12)
    }

    func dashboardRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(.footnote)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.footnote.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var effectiveOrg: String { org.isEmpty ? "ethansch061226" : org }
    var effectiveProperty: String { property.isEmpty ? "website_smart_tag" : property }
    var effectiveEnvironment: String { env.isEmpty ? "production" : env }

    func runHeadlessLocation() {
        dashboard.headlessLocationResult = "Loading..."
        KetchSDK.fetchLocation(dataCenter: apiRegion.dataCenter)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        dashboard.headlessLocationResult = "Error: \(error)"
                    }
                },
                receiveValue: { response in
                    let code = response.location?.countryCode ?? "?"
                    dashboard.headlessLocationResult = "OK: \(code)"
                    dashboard.appendLog("headless location: \(code)")
                }
            )
            .store(in: &headlessCancellables)
    }

    func runHeadlessBootstrap() {
        dashboard.headlessBootstrapResult = "Loading..."
        KetchSDK.fetchBootstrapConfiguration(
            organization: effectiveOrg,
            property: effectiveProperty,
            dataCenter: apiRegion.dataCenter
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    dashboard.headlessBootstrapResult = "Error: \(error)"
                }
            },
            receiveValue: { config in
                let purposeCount = config.purposes?.count ?? 0
                dashboard.headlessBootstrapResult = "OK: \(purposeCount) purpose(s)"
                dashboard.appendLog("headless bootstrap OK")
            }
        )
        .store(in: &headlessCancellables)
    }

    func runHeadlessConsent() {
        dashboard.headlessConsentResult = "Loading..."
        let identities = ["email": "headless-\(UUID().uuidString)@integration.ketch.test"]
        var bootConfig: KetchSDK.Configuration?
        var fullConfig: KetchSDK.Configuration?

        KetchSDK.fetchLocation(dataCenter: apiRegion.dataCenter)
            .flatMap { _ in
                KetchSDK.fetchBootstrapConfiguration(
                    organization: self.effectiveOrg,
                    property: self.effectiveProperty,
                    dataCenter: self.apiRegion.dataCenter
                )
            }
            .flatMap { boot in
                bootConfig = boot
                let request = KetchSDK.FullConfigurationRequest(
                    organizationCode: self.effectiveOrg,
                    propertyCode: self.effectiveProperty,
                    environmentCode: self.effectiveEnvironment
                )
                return KetchSDK.fetchFullConfiguration(request: request, dataCenter: self.apiRegion.dataCenter)
            }
            .flatMap { full in
                fullConfig = full
                let consentConfig = Self.consentConfig(
                    from: full,
                    identities: identities,
                    organization: self.effectiveOrg,
                    property: self.effectiveProperty,
                    environment: self.effectiveEnvironment
                )
                return KetchSDK.fetchConsent(config: consentConfig, dataCenter: self.apiRegion.dataCenter)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        dashboard.headlessConsentResult = "Error: \(error)"
                    }
                },
                receiveValue: { consent in
                    let purposes = consent.purposes?.count ?? 0
                    dashboard.headlessConsentResult = "OK: \(purposes) purpose(s)"
                    dashboard.appendLog("headless consent OK")
                    _ = bootConfig
                    _ = fullConfig
                }
            )
            .store(in: &headlessCancellables)
    }

    static func consentConfig(
        from configuration: KetchSDK.Configuration,
        identities: [String: String],
        organization: String,
        property: String,
        environment: String
    ) -> KetchSDK.ConsentConfig {
        let jurisdiction = configuration.jurisdiction?.code
            ?? configuration.jurisdiction?.defaultJurisdictionCode
            ?? "us"
        let purposesList = configuration.purposes ?? []
        let purposeMap = Dictionary(
            uniqueKeysWithValues: purposesList.map { purpose in
                (purpose.code, KetchSDK.ConsentConfig.PurposeLegalBasis(legalBasisCode: purpose.legalBasisCode))
            }
        )
        return KetchSDK.ConsentConfig(
            organizationCode: organization,
            propertyCode: property,
            environmentCode: environment,
            jurisdictionCode: jurisdiction,
            identities: identities,
            purposes: purposeMap
        )
    }
}

enum APIRegion {
    case us, eu, uat
    
    var name: String {
        switch self {
        case .us:
            return "Prod US"
        case .eu:
            return "Prod EU"
        case .uat:
            return "UAT"
        }
    }
    

    var dataCenter: KetchDataCenter {
        switch self {
        case .us: return .us
        case .eu: return .eu
        case .uat: return .uat
        }
    }

    var urlString: String {
        switch self {
        case .us:
            return "https://global.ketchcdn.com/web/v3"
        case .eu:
            return "https://eu.ketchcdn.com/web/v3"
        case .uat:
            return "https://dev.ketchcdn.com/web/v3"
        }
    }
}

#Preview {
    ContentView()
}
