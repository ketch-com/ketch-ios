//
//  SampleEventListener.swift
//  KetchSDK
//

import Foundation
import KetchSDK

class SampleEventListener: KetchEventListener {
    
    func onWillShowExperience(type: KetchSDK.WillShowExperienceType) {
        print("willShowExperience")
    }
    
    func onHasShownExperience() {
        print("hasShownExperience")
    }
    
    func onLoad() {
        print("UI Loaded")
    }

    func onShow() {
        print("UI Shown")
    }

    func onDismiss(status: KetchSDK.HideExperienceStatus) {
        print("UI Dismissed, Status: \(status)")
    }

    func onEnvironmentUpdated(environment: String?) {
        print("Environment Updated: \(String(describing: environment))")
    }

    func onRegionInfoUpdated(regionInfo: String?) {
        print("Region Info Updated: \(String(describing: regionInfo))")
    }

    func onJurisdictionUpdated(jurisdiction: String?) {
        print("Jurisdiction Updated: \(String(describing: jurisdiction))")
    }

    func onIdentitiesUpdated(identities: String?) {
        print("Identities Updated: \(String(describing: identities))")
    }

    func onConsentUpdated(consent: KetchSDK.ConsentStatus) {
        print("Consent Updated: \(consent)")
    }

    func onError(description: String) {
        print("Error: \(description)")
    }

    func onCCPAUpdated(ccpaString: String?) {
        print("CCPA String Updated: \(String(describing: ccpaString))")
    }

    func onTCFUpdated(tcfString: String?) {
        print("TCF String Updated: \(String(describing: tcfString))")
    }

    func onGPPUpdated(gppString: String?) {
        print("GPP String Updated: \(String(describing: gppString))")
    }
}
