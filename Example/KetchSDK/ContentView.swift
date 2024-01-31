//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK

struct ContentView: View {
    @ObservedObject var ketchUI: KetchUI
    
    init() {
        let ketch = KetchSDK.create(
            organizationCode: "bluebird",
            propertyCode: "mobile",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: [.idfa("00000000-0000-0000-0000-000000000000")] // or advertisingIdentifier.uuidString
        )
        
        ketchUI = KetchUI(
            ketch: ketch,
            experienceOptions: [
                .forceExperience(.cd)
            ]
        )
    }
    
    @State var selectedExperienceToShow: KetchUI.ExperienceOption.ExperienceToShow = .cd
    @State var selectedTab: KetchUI.ExperienceOption.PreferencesTab?
    @State var lang = "EN"
    @State var jurisdiction = "france"
    @State var region = "FR"
    
    @ViewBuilder
    private func checkbox(_ value: Binding<Bool>) -> some View {
        Button {
            value.wrappedValue.toggle()
        } label: {
            Image(systemName: value.wrappedValue ? "circle.fill" : "circle")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Experience:")
            Picker("Experience", selection: $selectedExperienceToShow) {
                ForEach([KetchUI.ExperienceOption.ExperienceToShow.cd, .preferences], id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
            
            if selectedExperienceToShow == .preferences {
                VStack(alignment: .leading) {
                    Text("Preferences tab:")
                    HStack {
                        Text("none")
                        checkbox(.init(get: { selectedTab == nil }, set: { _ in selectedTab = nil }))
                        Spacer()
                        Text("overview")
                        checkbox(.init(get: { selectedTab == .overviewTab }, set: { $0 ? (selectedTab = .overviewTab) : (selectedTab = nil) }))
                        Spacer()
                        Text("rights")
                        checkbox(.init(get: { selectedTab == .rightsTab }, set: { $0 ? (selectedTab = .rightsTab) : (selectedTab = nil) }))
                        Spacer()
                        Text("consents")
                        checkbox(.init(get: { selectedTab == .consentsTab }, set: { $0 ? (selectedTab = .consentsTab) : (selectedTab = nil) }))
                    }
                }
            }
            
            Text("Language:")
            Picker("Language", selection: $lang) {
                ForEach(["EN", "FR"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            
            Text("Jurisdiction:")
            Picker("Jurisdiction", selection: $jurisdiction) {
                ForEach(["france", "england___banner_momile_testing"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            
            
            Text("Region:")
            Picker("Region", selection: $region) {
                ForEach(["US", "FR", "GB"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Show") {
                    let params: [KetchUI.ExperienceOption?] = [
                        { if let selectedTab                                { return .preferencesTab(selectedTab) }                 else { return nil } }(),
                        .region(region),
                        .language(langId: lang),
                        .forceExperience(selectedExperienceToShow)
                        , .jurisdiction(code: jurisdiction)
                    ]
                    
                    ketchUI.overridePresentationConfig = nil
                    ketchUI.reload(with: params.compactMap{$0})
                }
                .font(.system(.title))
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Text("Animate Consent")
                VStack(spacing: 40) {
                    
                    HStack {
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .top, hpos: .center, style: .banner)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "arrow.down.square") }
                    }
                    
                    HStack {
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .center, hpos: .left, style: .modal)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "arrow.right.square") }
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .center, hpos: .center, style: .modal)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "square.on.square") }
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .center, hpos: .center, style: .banner)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "square") }
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .center, hpos: .right, style: .modal)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "arrow.left.square") }
                    }
                    
                    HStack(spacing: 10) {
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .bottom, hpos: .left, style: .banner)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "arrow.up.right.square") }
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .bottom, hpos: .center, style: .banner)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "arrow.up.square") }
                        Button {
                            ketchUI.overridePresentationConfig = KetchUI.PresentationConfig(vpos: .bottom, hpos: .right, style: .banner)
                            ketchUI.showConsent()
                        } label: { Image(systemName: "arrow.up.left.square") }
                    }
                }
                .padding()
                .border(.black)
            }
            
            Button("Preview privacy strings") {
                showPrivacyStrings()
            }
        }
        .padding()
        .background(.white)
        .ketchView(model: $ketchUI.webPresentationItem)
    }
    
    private func showPrivacyStrings() {
        let keys = ["IABTCF_CmpSdkID",
                    "IABTCF_CmpSdkVersion",
                    "IABTCF_PolicyVersion",
                    "IABTCF_gdprApplies",
                    "IABTCF_PublisherCC",
                    "IABTCF_PurposeOneTreatment",
                    "IABTCF_UseNonStandardTexts",
                    "IABTCF_TCString",
                    "IABTCF_VendorConsents",
                    "IABTCF_VendorLegitimateInterests",
                    "IABTCF_PurposeConsents",
                    "IABTCF_PurposeLegitimateInterests",
                    "IABTCF_SpecialFeaturesOptIns",
                    "IABTCF_PublisherConsent",
                    "IABTCF_PublisherLegitimateInterests",
                    "IABTCF_PublisherCustomPurposesConsents",
                    "IABTCF_PublisherCustomPurposesLegitimateInterests"]
        
        print("\n* ----- Begin privacy strings ---- *")
        keys.forEach {
            print("\($0): \(UserDefaults.standard.value(forKey: $0) ?? "")")
        }
        print("* ----- End privacy strings ---- *\n")
    }
}

extension KetchUI.ExperienceOption.ExperienceToShow {
    var name: String {
        switch self {
        case .cd:
            return "Consent"
        case .preferences:
            return "Preferences"
        }
    }
}

#Preview {
    ContentView()
}
