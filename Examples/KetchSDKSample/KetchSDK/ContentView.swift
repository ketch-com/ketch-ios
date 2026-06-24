//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK

struct ContentView: View {
    @StateObject var ketchUI: KetchUI
    @StateObject var dashboard = SampleDashboardState()

    // Define listener as a property of ContentView
    private let listener = SampleEventListener()
    
    init() {
        // Create the KetchSDK object
        let ketch = KetchSDK.create(
            // Replace below with your Ketch organization code
            organizationCode: "ethansch061226",
            // Repalce below with your Ketch property code
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            identities: [
                // Replace below with your Ketch identifier name and value
                Ketch.Identity(key: "email", value: "ethantest")
            ]
        )
        
        // Create the KetchUI object
        let ketchUI = KetchUI(ketch: ketch, experienceOptions: [.logLevel(.trace)])
        
        // Add our listener to the ketchUI class
        ketchUI.eventListener = listener
        
        _ketchUI = StateObject(wrappedValue: ketchUI)
    }
    
    @State private var selectedTabs: Set<KetchUI.ExperienceOption.PreferencesTab> = Set([.overviewTab, .consentsTab, .subscriptionsTab, .rightsTab])
    @State private var selectedTab = KetchUI.ExperienceOption.PreferencesTab.overviewTab
    @State var apiRegion = APIRegion.uat
    @State var org = ""
    @State var property = ""
    @State var env = ""
    @State private var lang = ""
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
            
            Spacer()
        }
        .padding()
        .background(.white)
        }
        .background(.white)
        .ketchView(model: $ketchUI.webPresentationItem)
        .onAppear {
            listener.dashboard = dashboard
            ketchUI.eventListener = listener
            refreshATTStatus()
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
