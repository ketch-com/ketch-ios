//
//  SampleEventListener.swift
//  KetchSDK
//

import Foundation
import KetchSDK

final class SampleEventListener: KetchEventListener {
    weak var dashboard: SampleDashboardState?

    func onWillShowExperience(type: KetchSDK.WillShowExperienceType) {
        Task { @MainActor in
            dashboard?.experienceVisibility = "will show: \(type)"
            dashboard?.appendLog("onWillShowExperience: \(type)")
        }
    }

    func onHasShownExperience() {
        Task { @MainActor in
            dashboard?.experienceVisibility = "shown"
            dashboard?.webViewVisible = "visible"
            dashboard?.appendLog("onHasShownExperience")
        }
    }

    func onLoad() {
        Task { @MainActor in
            dashboard?.loadState = "loaded"
            dashboard?.setStatus("WebView loaded")
        }
    }

    func onShow() {
        Task { @MainActor in
            dashboard?.experienceVisibility = "showing"
            dashboard?.webViewVisible = "visible"
            dashboard?.appendLog("onShow")
        }
    }

    func onDismiss(status: KetchSDK.HideExperienceStatus) {
        Task { @MainActor in
            dashboard?.experienceVisibility = "dismissed"
            dashboard?.dismissReason = "\(status)"
            dashboard?.webViewVisible = "hidden"
            dashboard?.appendLog("onDismiss: \(status)")
        }
    }

    func onEnvironmentUpdated(environment: String?) {
        Task { @MainActor in
            dashboard?.environment = environment ?? "Not set"
            dashboard?.appendLog("onEnvironmentUpdated: \(environment ?? "nil")")
        }
    }

    func onRegionInfoUpdated(regionInfo: String?) {
        Task { @MainActor in
            dashboard?.region = regionInfo ?? "Not set"
            dashboard?.appendLog("onRegionInfoUpdated: \(regionInfo ?? "nil")")
        }
    }

    func onJurisdictionUpdated(jurisdiction: String?) {
        Task { @MainActor in
            dashboard?.jurisdiction = jurisdiction ?? "Not set"
            dashboard?.appendLog("onJurisdictionUpdated: \(jurisdiction ?? "nil")")
        }
    }

    func onIdentitiesUpdated(identities: String?) {
        Task { @MainActor in
            dashboard?.appendLog("onIdentitiesUpdated: \(identities ?? "nil")")
        }
    }

    func onConsentUpdated(consent: KetchSDK.ConsentStatus) {
        Task { @MainActor in
            let summary = SampleLogging.formatConsent(consent)
            dashboard?.consent = summary
            dashboard?.appendLog("onConsentUpdated: \(summary)")
            print("[KetchSample] onConsentUpdated: \(summary)")
        }
    }

    func onError(description: String) {
        Task { @MainActor in
            dashboard?.loadState = "error"
            dashboard?.initState = "Error"
            dashboard?.setStatus("Error: \(description)")
        }
    }

    func onCCPAUpdated(ccpaString: String?) {
        Task { @MainActor in
            dashboard?.ccpa = ccpaString ?? "Not set"
            dashboard?.appendLog("onCCPAUpdated")
        }
    }

    func onTCFUpdated(tcfString: String?) {
        Task { @MainActor in
            dashboard?.tcf = tcfString ?? "Not set"
            dashboard?.appendLog("onTCFUpdated")
        }
    }

    func onGPPUpdated(gppString: String?) {
        Task { @MainActor in
            dashboard?.gpp = gppString ?? "Not set"
            dashboard?.appendLog("onGPPUpdated")
        }
    }

    func onNativeStoragePut(key: String, value: String) {
        Task { @MainActor in
            if key == SampleLogging.attLastStatusKey {
                let message = SampleLogging.formatAttState(
                    current: dashboard?.ketchAtt ?? value,
                    previous: value
                )
                dashboard?.appendLog("onNativeStoragePut: \(key)=\(value)")
                print("[KetchSample] onNativeStoragePut (ATT): \(message)")
            } else {
                dashboard?.appendLog("onNativeStoragePut: \(key)=\(value)")
            }
        }
    }
}
