//
//  IntegrationViewModel.swift
//  KetchIntegrationTests
//
//  Created for Ketch iOS SDK Integration Tests
//

import Foundation
import Combine
import KetchSDK


class IntegrationViewModel: ObservableObject, KetchEventListener {
    // MARK: - Published Properties
    @Published var statusText: String = "Initializing..."
    @Published var environmentText: String = "Environment: Not set"
    @Published var consentText: String = "Consent: Not set"
    @Published var usPrivacyText: String = "US Privacy: Not set"
    @Published var tcfText: String = "TCF: Not set"
    @Published var gppText: String = "GPP: Not set"
    @Published var testResultText: String = ""
    
    // MARK: - Private Properties
    private var ketch: Ketch!
    private var ketchUI: KetchUI!
    private var cancellables = Set<AnyCancellable>()
    
    private let orgCode = "ketch_samples"
    private let propertyCode = "ios"
    private let environmentCode = "production"
    
    // Track which dialog was requested last so we can validate its presence without
    // touching internal SDK APIs.
    private enum ExperienceType {
        case consent, preferences, none
    }
    
    private var lastRequestedExperience: ExperienceType = .none
    
    // MARK: - Initialization
    func initialize() {
        setupKetch()
        statusText = "Ketch initialized"
    }
    
    private func setupKetch() {
        // Create a random identity similar to IDFA
        let identityValue = UUID().uuidString
        let identity = Ketch.Identity(key: "idfa", value: identityValue)
        
        // Initialize Ketch core
        ketch = KetchSDK.create(
            organizationCode: orgCode,
            propertyCode: propertyCode,
            environmentCode: environmentCode,
            identities: [identity]
        )
        
        // Initialize KetchUI with the Ketch core
        ketchUI = KetchUI(ketch: ketch)
        ketchUI.eventListener = self
        
        // Bind to configuration changes to trigger consent load
        ketch.$configuration
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.statusText = "Config updated"
                self?.ketch.loadConsent()
            }
            .store(in: &cancellables)
        
        // Preload web experience
        ketchUI.bindInput()
    }
    
    // MARK: - Public Methods (Android-equivalent actions)
    
    func load() {
        ketch.loadConfiguration()
        statusText = "Load called"
        // Force the consent experience to appear (mirrors Android test flow) and enable debug logs
        ketchUI.reload(with: [.forceExperience(.consent), .logLevel(.debug)])
    }
    
    func showConsent() {
        ketchUI.showConsent()
        statusText = "Show consent called"
        lastRequestedExperience = .consent
    }
    
    func showPreferences() {
        ketchUI.showPreferences()
        statusText = "Show preferences called"
        lastRequestedExperience = .preferences
    }
    
    func setLanguageEN() {
        ketchUI.reload(with: [.language(code: "EN")])
        statusText = "Language set to EN"
    }
    
    func setJurisdictionUS() {
        ketchUI.reload(with: [.jurisdiction(code: "US")])
        statusText = "Jurisdiction set to US"
    }
    
    func setRegionCalifornia() {
        ketchUI.reload(with: [.region(code: "California")])
        statusText = "Region set to California"
    }
    
    // MARK: - Test Mode Helpers
    
    func validateWebViewContent(expectedInnerElementId: String) {
        let isPresented = ketchUI.webPresentationItem != nil
        
        let expectedExperience: ExperienceType
        switch expectedInnerElementId {
        case "ketch-consent-banner":
            expectedExperience = .consent
        case "ketch-preferences":
            expectedExperience = .preferences
        default:
            expectedExperience = .none
        }
        
        let matches = isPresented && (expectedExperience == lastRequestedExperience)
        testResultText = "\(expectedInnerElementId):\(matches)"
    }
    
    func clickButtonById(buttonId: String) {
        // In test mode we simply close the experience to simulate a user action.
        if ketchUI.webPresentationItem != nil {
            ketchUI.closeExperience()
            testResultText = "click:\(buttonId):true"
            lastRequestedExperience = .none
        } else {
            testResultText = "click:\(buttonId):false"
        }
    }
    
    func updateIdentitiesWithUniqueValue() {
        // Cancel existing subscriptions
        cancellables.removeAll()
        
        // Create a new unique identity
        let uniqueId = UUID().uuidString
        let identity = Ketch.Identity(key: "idfa", value: uniqueId)
        
        // Re-initialize Ketch with the new identity
        ketch = KetchSDK.create(
            organizationCode: orgCode,
            propertyCode: propertyCode,
            environmentCode: environmentCode,
            identities: [identity]
        )
        
        // Re-initialize KetchUI
        ketchUI = KetchUI(ketch: ketch)
        ketchUI.eventListener = self
        
        // Rebind configuration changes
        ketch.$configuration
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.statusText = "Config updated"
                self?.ketch.loadConsent()
            }
            .store(in: &cancellables)
        
        // Preload web experience
        ketchUI.bindInput()
        
        statusText = "Updated identities with unique ID: \(uniqueId)"
    }
    
    // MARK: - KetchEventListener Implementation
    
    func onLoad() {
        // Not used in Android implementation
    }
    
    func onShow() {
        DispatchQueue.main.async { [weak self] in
            self?.statusText = "Dialog shown"
        }
    }
    
    func onDismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.statusText = "Dialog dismissed"
        }
    }
    
    func onEnvironmentUpdated(environment: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.environmentText = "Environment: \(environment ?? "Not set")"
        }
    }
    
    func onRegionInfoUpdated(regionInfo: String?) {
        // Not displayed in Android implementation
    }
    
    func onJurisdictionUpdated(jurisdiction: String?) {
        // Not displayed in Android implementation
    }
    
    func onIdentitiesUpdated(identities: String?) {
        // Not displayed in Android implementation
    }
    
    func onConsentUpdated(consent: KetchSDK.ConsentStatus) {
        DispatchQueue.main.async { [weak self] in
            let purposesCount = consent.purposes?.count ?? 0
            self?.consentText = "Consent: \(purposesCount) purposes"
        }
    }
    
    func onError(description: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusText = "Error: \(description)"
        }
    }
    
    func onCCPAUpdated(ccpaString: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.usPrivacyText = "US Privacy: \(ccpaString ?? "Not set")"
        }
    }
    
    func onTCFUpdated(tcfString: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.tcfText = "TCF: \(tcfString ?? "Not set")"
        }
    }
    
    func onGPPUpdated(gppString: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.gppText = "GPP: \(gppString ?? "Not set")"
        }
    }
    
    // Helper functions for checking WebView content (similar to Android)
    func checkForConsentBanner(completion: @escaping (Bool) -> Void) {
        validateWebViewContent(expectedInnerElementId: "ketch-consent-banner")
        // We can't directly return the result because evaluateJavaScript is asynchronous
        // The UI test will need to check the testResultText
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = self.testResultText.contains(":true")
            completion(result)
        }
    }
    
    func checkForPreferencesCenter(completion: @escaping (Bool) -> Void) {
        validateWebViewContent(expectedInnerElementId: "ketch-preferences")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = self.testResultText.contains(":true")
            completion(result)
        }
    }
}
