//
//  ContentView+Dashboard.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK
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

    /// Reads the current ATT status from the SDK + the previously stored status from native
    /// storage and reflects both on the dashboard. The SDK injects these into the WebView as
    /// `ketch_att` / `ketch_att_prev` on the next load/reload.
    func refreshATTStatus(logEvent: Bool = false) {
        #if canImport(AppTrackingTransparency)
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
        #endif
    }

    func requestATT() {
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
