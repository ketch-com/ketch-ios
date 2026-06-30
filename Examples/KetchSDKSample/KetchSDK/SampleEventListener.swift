//
//  SampleEventListener.swift
//  KetchSDK
//

import Foundation
import KetchSDK

final class SampleEventListener: KetchEventListener {
    /// Backs the live Info panel fields. Jurisdiction/region callbacks push into this.
    weak var info: SampleInfoState?

    func onWillShowExperience(type: KetchSDK.WillShowExperienceType) {
        print("[KetchSample] onWillShowExperience: \(type)")
    }

    func onHasShownExperience() {
        print("[KetchSample] onHasShownExperience")
    }

    func onShow() {
        print("[KetchSample] onShow")
    }

    func onDismiss(status: KetchSDK.HideExperienceStatus) {
        print("[KetchSample] onDismiss: \(status)")
    }

    func onEnvironmentUpdated(environment: String?) {
        print("[KetchSample] onEnvironmentUpdated: \(environment ?? "nil")")
    }

    func onRegionInfoUpdated(regionInfo: String?) {
        print("[KetchSample] onRegionInfoUpdated: \(regionInfo ?? "nil")")
        Task { @MainActor in
            info?.region = regionInfo ?? ""
        }
    }

    func onJurisdictionUpdated(jurisdiction: String?) {
        print("[KetchSample] onJurisdictionUpdated: \(jurisdiction ?? "nil")")
        Task { @MainActor in
            info?.jurisdiction = jurisdiction ?? ""
        }
    }

    func onIdentitiesUpdated(identities: String?) {
        print("[KetchSample] onIdentitiesUpdated: \(identities ?? "nil")")
    }

    func onConsentUpdated(consent: KetchSDK.ConsentStatus) {
        print("[KetchSample] onConsentUpdated: \(SampleLogging.formatConsent(consent))")
    }

    func onError(description: String) {
        print("[KetchSample] onError: \(description)")
    }

    func onCCPAUpdated(ccpaString: String?) {
        print("[KetchSample] onCCPAUpdated: \(ccpaString ?? "nil")")
    }

    func onTCFUpdated(tcfString: String?) {
        print("[KetchSample] onTCFUpdated: \(tcfString ?? "nil")")
    }

    func onGPPUpdated(gppString: String?) {
        print("[KetchSample] onGPPUpdated: \(gppString ?? "nil")")
    }

    func onNativeStoragePut(key: String, value: String) {
        print("[KetchSample] onNativeStoragePut: \(key)=\(value)")
    }
}
