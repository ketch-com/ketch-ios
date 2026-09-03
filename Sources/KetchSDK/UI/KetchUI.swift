//
//  KetchUI.swift
//  KetchSDK
//

import SwiftUI
import Combine
import WebKit

/// Container for UI features
public final class KetchUI: ObservableObject {
    /// Stream of UI dialogs required to show
    @Published public var webPresentationItem: WebPresentationItem?

    /// Configuration updates stream
    /// Reflected from Ketch dependency
    @Published public var configuration: KetchSDK.Configuration?
    
    /// Localized Strings updates stream
    /// Reflected from Ketch dependency
    @Published public var localizedStrings: KetchSDK.LocalizedStrings?

    /// Consent updates stream
    /// Reflected from Ketch dependency
    @Published public var consentStatus: KetchSDK.ConsentStatus?

    public weak var eventListener: KetchEventListener?

    private(set) public var ketch: Ketch
    private var subscriptions = Set<AnyCancellable>()
    private var options = [ExperienceOption]()
    // Whether the *currently loaded* page's tag has finished booting (emitted .configurationLoaded).
    // Distinct from "an experience is pending" (experienceToShow) or "queued" (pendingTrigger) --
    // those track what should happen once the tag boots, this tracks whether it has.
    var isTagBooted = false
    private var experienceToShow: KetchUI.WebPresentationItem.Event.Content?
    private var preloadedPresentationItem: WebPresentationItem?

    // Deferred trigger() call, fired once a cold-booted WebView's tag finishes loading.
    // internal, not private: see isTagBooted's comment above.
    var pendingTrigger: PendingTrigger?

    // A show requested while the first resolve is still in flight. evaluateJavaScript on a WebView
    // that does not exist yet is a silent no-op, so without this the request disappears.
    private var pendingShow: ExperienceOption.ExperienceToShow?
    private var pendingShowExperience = false

    // Resolves for different properties are independent and unordered, so a reload that
    // switches property can finish before the build it replaced. Without this, the older
    // build installs last and silently reverts the reload.
    private var buildGeneration = 0

    struct PendingTrigger {
        let triggerName: TriggerName
        let functionName: String
        let optionsJson: String
    }

    /// Instantiation of UI dialogs
    /// - Parameter ketch: Instance of Ketch that will provide request and storage services,
    /// - Parameter options: default options
    /// protocol plugins updates
    public init(ketch: Ketch, experienceOptions options: [ExperienceOption] = []) {
        self.ketch = ketch
        self.options = options
        
        bindInput()
    }

    private func bindInput() {
        preloadWebExperience()
        
        ketch.$configuration
            .sink { configuration in
                self.configuration = configuration
            }
            .store(in: &subscriptions)
        
        ketch.$localizedStrings
            .sink { localizedStrings in
                self.localizedStrings = localizedStrings
            }
            .store(in: &subscriptions)

        ketch.$consent
            .sink { consentStatus in
                self.consentStatus = consentStatus
            }
            .store(in: &subscriptions)
    }
    
    private func preloadWebExperience() {
        buildPresentation(options: experienceOptionsWithDataCenter(options))
    }

    /// Builds the WebView, waiting for the Ketch-managed identifier when this property has not
    /// resolved one yet.
    ///
    /// The identifier has to be known before the WebView is built, because it is carried as a query
    /// parameter on the document URL that `loadHTMLString` is given -- injecting it afterwards would
    /// mean rebuilding the WebView and re-booting the tag.
    private func buildPresentation(options: [ExperienceOption]) {
        let scope = identityScope(for: options)

        resetBridgeState()

        buildGeneration += 1
        let generation = buildGeneration

        // Repeat resolves for a property already fetched are answered from the resolver's memo
        // without touching the network, so a reload does not wait on a config request again.
        ketch.resolveManagedIdentity(
            organizationCode: scope.organization,
            propertyCode: scope.property
        ) { [weak self] resolved in
            DispatchQueue.main.async {
                guard let self, self.buildGeneration == generation else { return }
                self.install(options: options, resolved: resolved)
            }
        }
    }

    private func install(options: [ExperienceOption], resolved: ManagedIdentity.Resolved?) {
        preloadedPresentationItem = webExperience(onEvent: handle, managedIdentity: resolved)
        preloadedPresentationItem?.reload(options: options)
        flushPendingShow()
    }

    /// The organization and property the identity space is looked up under, which an experience
    /// option may override for this build.
    private func identityScope(for options: [ExperienceOption]) -> (organization: String, property: String) {
        var organization = ketch.organizationCode
        var property = ketch.propertyCode
        options.forEach { option in
            switch option {
            case .organizationCode(let code): organization = code
            case .propertyCode(let code): property = code
            default: break
            }
        }
        return (organization, property)
    }

    private func flushPendingShow() {
        if pendingShowExperience {
            pendingShowExperience = false
            webPresentationItem = preloadedPresentationItem
        }
        guard let pending = pendingShow else { return }
        pendingShow = nil
        switch pending {
        case .consent: preloadedPresentationItem?.showConsent()
        case .preferences: preloadedPresentationItem?.showPreferences()
        }
    }

    // Single choke point for "a new page is about to load". Resets the state that describes the
    // *current* page, but deliberately leaves pendingTrigger alone -- a trigger() queued before a
    // reload should still fire once the new page's tag boots, not be discarded by the reload.
    private func resetBridgeState() {
        isTagBooted = false
        // The current page's script handlers are about to be removed, so no .onClose can arrive
        // for an experience still on screen -- close it here instead of stranding it.
        if webPresentationItem != nil {
            didCloseExperience(status: .None)
        }
        // Torn down synchronously even though the replacement WebView may not exist until the
        // managed identifier resolves: until then the old page must not still look current, or
        // events it emits during the wait are handled as though they came from the new one.
        preloadedPresentationItem?.webView?.configuration.userContentController.removeAllScriptMessageHandlers()
        preloadedPresentationItem = nil
    }

    private func experienceOptionsWithDataCenter(_ options: [ExperienceOption]) -> [ExperienceOption] {
        guard !options.contains(where: { if case .ketchURL = $0 { return true }; return false }) else {
            return options
        }
        var result = options
        result.append(.ketchURL(ketch.dataCenter.baseURL.absoluteString))
        return result
    }
    
    func handle(webPresentationEvent: WebPresentationItem.Event) {
        switch webPresentationEvent {
        case .onClose(let status):
            didCloseExperience(status: status)
            
        case .show(let content):
            presentExperience(content)

        case .willShowExperience(let type):
            eventListener?.onWillShowExperience(type: type)
            ketch.notifyWillShowExperience()
            // The only show signal guaranteed to fire for every experience path. .None is also
            // the fallback for an unparseable event body, so it must not present anything.
            switch type {
            case .ConsentExperience: presentExperience(.consent)
            case .PreferenceExperience: presentExperience(.preference)
            case .None: break
            }
            
        case .hasShownExperience:
            eventListener?.onHasShownExperience()
            
        case .tapOutside:
            didCloseExperience(status: KetchSDK.HideExperienceStatus.None)
            
        case .configurationLoaded(let configuration):
            self.ketch.configuration = configuration

            isTagBooted = true

            if let pending = pendingTrigger {
                pendingTrigger = nil
                preloadedPresentationItem?.trigger(
                    triggerName: pending.triggerName.rawValue,
                    functionName: pending.functionName,
                    optionsJson: pending.optionsJson
                )
            }

            if experienceToShow != nil {
                showExperience()
                self.experienceToShow = nil
                eventListener?.onShow()
            }

        case .onCCPAUpdated(let value):
            eventListener?.onCCPAUpdated(ccpaString: value)
            
        case .onTCFUpdated(let value):
            eventListener?.onTCFUpdated(tcfString: value)
            
        case .onGPPUpdated(let value):
            eventListener?.onGPPUpdated(gppString: value)
            
        case .onConsentUpdated(let consent):
            eventListener?.onConsentUpdated(consent: consent)

        case .nativeStoragePut(let key, let value):
            eventListener?.onNativeStoragePut(key: key, value: value)
            
        case .error(let description):
            eventListener?.onError(description: description)
        case .environment(let env):
            eventListener?.onEnvironmentUpdated(environment: env)
            
        case .regionInfo(let region):
            eventListener?.onRegionInfoUpdated(regionInfo: region)
            
        case .jurisdiction(let jurisdiction):
            eventListener?.onJurisdictionUpdated(jurisdiction: jurisdiction)
            
        case .identities(let identities):
            eventListener?.onIdentitiesUpdated(identities: identities)
        }
    }
    
    private func didCloseExperience(status: KetchSDK.HideExperienceStatus) {
        webPresentationItem = nil
        eventListener?.onDismiss(status: status)
        ketch.notifyExperienceHidden(status: status)
    }

    private func presentExperience(_ content: WebPresentationItem.Event.Content) {
        guard isTagBooted, preloadedPresentationItem != nil else {
            experienceToShow = content
            return
        }
        // .show and .willShowExperience both fire for the same experience on the warm path;
        // only the first to arrive should actually dispatch showExperience()/onShow().
        guard webPresentationItem == nil else { return }
        experienceToShow = nil
        showExperience()
        eventListener?.onShow()
    }
    
    private var display: KetchSDK.Configuration.Experience.ContentDisplay {
        ketch.configuration?.experiences?.content?.display
        ?? .banner
    }
        
    private var bannerPosition: KetchSDK.Configuration.BannerContainerConfig.Position {
        ketch.configuration?.theme?.banner?.container?.position
        ?? .bottomMiddle
    }
    
    private var modalPosition: KetchSDK.Configuration.ModalContainerConfig.Position {
        ketch.configuration?.theme?.modal?.container?.position
        ?? .center
    }
}

// MARK: - Direct trigger of dialog item presentation
extension KetchUI {
    public func reload(with options: [ExperienceOption] = []) {
        // merge options, override existing if needed
        var newOptions = self.options
        options.forEach { option in
            if let duplicateIndex = newOptions.firstIndex(of: option) {
                newOptions.remove(at: duplicateIndex)
            }
            
            newOptions.append(option)
        }

        buildPresentation(options: experienceOptionsWithDataCenter(newOptions))
    }
    
    public func showExperience() {
        // Assigning nil here would dismiss an experience that is already on screen, and dropping
        // the request would silently do nothing for a caller that reloaded a moment earlier.
        guard preloadedPresentationItem != nil else {
            pendingShowExperience = true
            return
        }
        webPresentationItem = preloadedPresentationItem
    }

    public func showPreferences() {
        experienceToShow = .preference
        guard preloadedPresentationItem != nil else {
            pendingShow = .preferences
            return
        }
        preloadedPresentationItem?.showPreferences()
    }
    
    public func showConsent() {
        experienceToShow = .consent
        guard preloadedPresentationItem != nil else {
            pendingShow = .consent
            return
        }
        preloadedPresentationItem?.showConsent()
    }
    
    public func closeExperience() {
        guard webPresentationItem != nil else { return }
        didCloseExperience(status: .None)
    }

    /// Fires a custom-function (`onFunction`) rule trigger. If a matching backend rule shows an
    /// experience, it is displayed automatically.
    ///
    /// - Parameters:
    ///   - triggerName: the trigger name; `.custom` is the only supported value today
    ///   - functionName: the custom function name configured on the backend rule
    ///   - options: optional key/value trigger arguments
    /// - Returns: `false` if `functionName` is invalid, or an experience is already showing.
    @discardableResult
    public func trigger(
        triggerName: TriggerName,
        functionName: String,
        options: [String: Any] = [:]
    ) -> Bool {
        guard Self.isValidTriggerFunctionName(functionName) else {
            KetchLogger.log.debug("[Ketch] trigger rejected: functionName must be non-blank and contain only letters, digits, '_', '-', or '.'")
            return false
        }
        guard webPresentationItem == nil else {
            KetchLogger.log.debug("Not triggering '\(functionName)' as an experience is already being shown")
            return false
        }

        let optionsJson = Self.jsonString(from: options)

        if isTagBooted {
            pendingTrigger = nil
            preloadedPresentationItem?.trigger(triggerName: triggerName.rawValue, functionName: functionName, optionsJson: optionsJson)
        } else {
            pendingTrigger = PendingTrigger(triggerName: triggerName, functionName: functionName, optionsJson: optionsJson)
        }
        return true
    }

    /// Mirrors ketch-tag's function-name validation: non-blank, and only letters, digits, '_', '-', or '.'.
    static func isValidTriggerFunctionName(_ functionName: String) -> Bool {
        !functionName.isEmpty
            && functionName.range(of: "^[A-Za-z0-9_.-]+$", options: .regularExpression) != nil
    }

    private static func jsonString(from options: [String: Any]) -> String {
        // data(withJSONObject:) raises an ObjC exception on non-serializable values, and try?
        // does not catch those.
        guard JSONSerialization.isValidJSONObject(options),
              let data = try? JSONSerialization.data(withJSONObject: options),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
}

// MARK: - Public
extension KetchUI {
    public enum ExperienceOption: Equatable {
        
        /// Enables console logging by Ketch components
        case logLevel(LogLevel)
        
        /// Forces an experience to show
        case forceExperience(ExperienceToShow)
        
        /// Overrides organization code
        case organizationCode(String)
        
        /// Overrides property code
        case propertyCode(String)
        
        /// Overrides environment detection and uses a specific environment
        case environment(String)
        
        /// ISO-3166 country code overrides region detection and uses a specific region
        case region(code: String)
        
        /// Jurisdiction code overrides jurisdiction detection and uses a specific jurisdiction
        case jurisdiction(code: String)
        
        /// ISO 639-1 language code, with optional regional extension overrides language detection and uses a specific language
        case language(code: String)
        
        /// Default tab that will be opened
        case preferencesTab(PreferencesTab)
        
        /// Comma separated list of tabs to display on the preference experience
        case preferencesTabs(String)
        
        /// URL string for SDK, including `https://`
        case ketchURL(String)
        
        /// Overrides identities passed on init
        case identity(Ketch.Identity)
        
        /// Inject CSS into the Ketch UI
        case css(String)

        /// Exact-match WebView resource URL replacements (e.g. UAT tag scripts → local dev server).
        case webResourceUrlOverrides([String: String])

        /// Exact age for age band legal basis resolution
        case age(UInt)

        /// Lower bound of age range for age band legal basis resolution
        case ageLower(UInt)

        /// Upper bound of age range for age band legal basis resolution
        case ageUpper(UInt)

        public enum ExperienceToShow: String {
            case consent, preferences
        }
        
        public enum PreferencesTab: String, CaseIterable {
            case overviewTab, rightsTab, consentsTab, subscriptionsTab
        }
        
        public enum LogLevel: String, Codable {
            case trace, debug, info, warn, error
        }
        
        public static func == (lhs: ExperienceOption, rhs: ExperienceOption) -> Bool {
            switch (lhs, rhs) {
            case (.logLevel(_), .logLevel(_)):
                return true
            case (.forceExperience(_), .forceExperience(_)):
                return true
            case (.environment(_), .environment(_)):
                return true
            case (.region(code: _), .region(code: _)):
                return true
            case (.jurisdiction(code: _), .jurisdiction(code: _)):
                return true
            case (.language(code: _), .language(code: _)):
                return true
            case (.preferencesTab(_), .preferencesTab(_)):
                return true
            case (.preferencesTabs(_), .preferencesTabs(_)):
                return true
            case (.ketchURL(_), .ketchURL(_)):
                return true
            case (.age(_), .age(_)):
                return true
            case (.ageLower(_), .ageLower(_)):
                return true
            case (.ageUpper(_), .ageUpper(_)):
                return true
            case (.webResourceUrlOverrides(_), .webResourceUrlOverrides(_)):
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Dialog presentation item generation of each type
extension KetchUI {
    private func webExperience(
        onEvent: ((WebPresentationItem.Event) -> Void)?,
        managedIdentity: ManagedIdentity.Resolved?
    ) -> WebPresentationItem? {
        WebPresentationItem(
            item: .init(
                orgCode: ketch.organizationCode,
                propertyName: ketch.propertyCode,
                environmentCode: ketch.environmentCode,
                identities: ManagedIdentity.merged(ketch.identities, with: managedIdentity)
            ),
            onEvent: onEvent
        )
    }
}

// MARK: - Dialog presentation item generation of each type

public protocol KetchEventListener: AnyObject {
    func onShow()
    func onWillShowExperience(type: KetchSDK.WillShowExperienceType)
    func onHasShownExperience()
    func onDismiss(status: KetchSDK.HideExperienceStatus)
    func onEnvironmentUpdated(environment: String?)
    func onRegionInfoUpdated(regionInfo: String?)
    func onJurisdictionUpdated(jurisdiction: String?)
    func onIdentitiesUpdated(identities: String?)
    func onConsentUpdated(consent: KetchSDK.ConsentStatus)
    func onError(description: String)
    func onCCPAUpdated(ccpaString: String?)
    func onTCFUpdated(tcfString: String?)
    func onGPPUpdated(gppString: String?)
    func onNativeStoragePut(key: String, value: String)
}

public extension KetchEventListener {
    func onNativeStoragePut(key: String, value: String) {}
}
