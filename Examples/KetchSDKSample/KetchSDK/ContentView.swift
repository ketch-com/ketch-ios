//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// The single place a developer edits sample configuration. Both the SDK init and the
/// read-only Info panel read from this.
struct SampleConfig {
    let organizationCode: String
    let propertyCode: String
    let environmentCode: String
    let language: String
    let jurisdiction: String
    let region: String
    let identities: [Ketch.Identity]
    let apiRegion: APIRegion

    static let `default` = SampleConfig(
        organizationCode: "ketch_samples",
        propertyCode: "ios",
        environmentCode: "production",
        language: "en",
        jurisdiction: "",
        region: "",
        identities: [
            Ketch.Identity(key: "email", value: "test@example.com")
        ],
        apiRegion: .us
    )
}

struct ContentView: View {
    private let config = SampleConfig.default

    @StateObject var ketchUI: KetchUI
    @StateObject private var info: SampleInfoState

    private let listener = SampleEventListener()

    init() {
        let config = SampleConfig.default

        let info = SampleInfoState(jurisdiction: config.jurisdiction, region: config.region)
        listener.info = info
        _info = StateObject(wrappedValue: info)

        let ketch = KetchSDK.create(
            organizationCode: config.organizationCode,
            propertyCode: config.propertyCode,
            environmentCode: config.environmentCode,
            identities: config.identities
        )

        let ketchUI = KetchUI(ketch: ketch, experienceOptions: [.logLevel(.trace)])
        ketchUI.eventListener = listener

        _ketchUI = StateObject(wrappedValue: ketchUI)
    }

    @State private var selectedTabs: Set<KetchUI.ExperienceOption.PreferencesTab> = Set([.overviewTab, .consentsTab, .subscriptionsTab, .rightsTab])
    @State private var selectedTab = KetchUI.ExperienceOption.PreferencesTab.overviewTab

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Info")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 6) {
                    infoRow("Org Code", config.organizationCode)
                    infoRow("Property", config.propertyCode)
                    infoRow("Environment", config.environmentCode)
                    infoRow("Language", config.language)
                    infoRow("Jurisdiction", display(info.jurisdiction))
                    infoRow("Region", display(info.region))
                }
                .padding(.top, 8)
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

                Text("Initial Tab")
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

                    #if canImport(AppTrackingTransparency)
                    if #available(iOS 14, *) {
                        Spacer()

                        Button("Request ATT") {
                            requestATT()
                        }
                    }
                    #endif
                }
                .padding(.vertical)

                Spacer()
            }
            .padding()
            .background(.white)
        }
        .background(.white)
        .ketchView(model: $ketchUI.webPresentationItem)
        .onAppear {
            refreshATTStatus(logEvent: true)
        }
    }

    var makeParameters: [KetchUI.ExperienceOption] {
        var parameters = [KetchUI.ExperienceOption]()

        parameters.append(.organizationCode(config.organizationCode))
        parameters.append(.propertyCode(config.propertyCode))
        parameters.append(.environment(config.environmentCode))
        parameters.append(.language(code: config.language))

        if !config.jurisdiction.isEmpty {
            parameters.append(.jurisdiction(code: config.jurisdiction))
        }

        if !config.region.isEmpty {
            parameters.append(.region(code: config.region))
        }

        parameters.append(.ketchURL(config.apiRegion.urlString))

        config.identities.forEach { identity in
            parameters.append(.identity(identity))
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

        print("\n* ----- Begin privacy strings ---- *")
        (keys + keys2 + keys3).forEach {
            print("\($0): \(UserDefaults.standard.value(forKey: $0) ?? "")")
        }
        print("* ----- End privacy strings ---- *\n")
    }

    private func applyCSS() {
        var parameters = makeParameters
        parameters.append(.css("#ketch-banner-button-primary { display: none !important; }"))
        parameters.append(.forceExperience(.consent))
        ketchUI.reload(with: parameters)
    }

    /// Reads the current ATT status from the SDK + the previously stored status from native
    /// storage and logs both. The SDK injects these into the WebView as `ketch_att` /
    /// `ketch_att_prev` on the next load/reload.
    private func refreshATTStatus(logEvent: Bool = false) {
        #if canImport(AppTrackingTransparency)
        guard logEvent else { return }
        if #available(iOS 14, *) {
            let status = KetchSDK.trackingAuthorizationStatusString()
            let prev = SampleLogging.storedAttPrev()
            print("[KetchSample] ATT: \(SampleLogging.formatAttState(current: status, previous: prev))")
        }
        #endif
    }

    private func requestATT() {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    self.refreshATTStatus(logEvent: true)
                    self.ketchUI.reload(with: self.makeParameters)
                }
            }
        }
        #endif
    }
}

// MARK: - UI

fileprivate extension ContentView {
    func display(_ value: String) -> String {
        value.isEmpty ? "—" : value
    }

    func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(.subheadline)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.subheadline.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
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
