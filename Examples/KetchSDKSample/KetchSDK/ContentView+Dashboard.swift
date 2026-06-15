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
                        refreshATTStatus()
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

extension APIRegion {
    var dataCenter: KetchDataCenter {
        switch self {
        case .us: return .us
        case .eu: return .eu
        case .uat: return .uat
        }
    }
}
