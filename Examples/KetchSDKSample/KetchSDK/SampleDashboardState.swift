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
