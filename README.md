# Ketch Mobile SDK for iOS

The Ketch Mobile SDK provides iOS and Android native integration of Ketch's consent and preference management capabilities.

## Mobile SDK Beta Program Disclaimer

Thank you for your interest in our Mobile SDK Beta Program! 

Before proceeding, please note that this version of the software library is in its 
BETA stage. While we have made efforts to ensure functionality and stability, 
there may still be bugs or incomplete features present.

To ensure a smooth experience and access to the full capabilities of the SDK, 
we kindly request that all users contact our customer support team 
to enroll their organization in the Beta program. 

Once approved, you will receive necessary credentials and information to begin 
using the SDK effectively.

Please reach out to [customer support](mailto:support@ketch.com) to initiate the enrollment process.

Your feedback during this Beta period is invaluable to us as we work towards the official release. 
Thank you for your collaboration and understanding.

## Requirements

This SDK supports iOS version 15.0 and above.

The minimum required version of Xcode is 15.0. 

The minimum required version of Swift is 5.5.

The use of the Mobile SDK requires an [Ketch organization account](https://app.ketch.com/settings/organization) 
with the [application property](https://app.ketch.com/deployment/applications)  configured.

## Sandbox
The SDK provides a pre-registered sample organization for quick testing and evaluation. While convenient, it’s advisable to switch to your own organization promptly. Your own organization ensures isolation, security, scalability, and tailored support, optimizing your development process. Simply sign up for a new account, update SDK configurations, and transition seamlessly for production readiness and long-term usage.

A sandbox organization and configuration is available for development and tests:

Organization: ketch_samples

Property: ios

Boot.js: https://global.ketchcdn.com/web/v3/config/ketch_samples/ios/boot.js

Site: https://ketch-com.github.io/testing-sites/prod/ketch_samples_ios.html

## Quick Start

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Add the Ketch iOS SDK as a dependency to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

   ```swift
   dependencies: [
       .package(url: "https://github.com/ketch-com/ketch-ios.git", .upToNextMajor(from: "3.0.0"))
   ]
   ```
## Setup

### Step 1. Instantiate the Ketch and KetchUI objects

```swift
var ketch: Ketch?
var ketchUI: KetchUI?
```
    
```swift
private func setupKetch(advertisingIdentifier: UUID) {
   let ketch = KetchSDK.create(
      organizationCode: "#{your_org_code}#",
      propertyCode: "#{your_property}#",
      environmentCode: "#{your_environment}#",
      identities: [
          Ketch.Identity(key: "aaid", value: "00000000-0000-0000-0000-000000000000"),
          Ketch.Identity(key: "email", value: "user@mywebsite.com"),
          Ketch.Identity(key: "account_id", value: "1234")
      ]
   )
   self.ketch = ketch
}
```

### Step 2.  Instantiate the KetchUI object:

```swift
ketchUI = KetchUI(ketch: ketch)
```

### Step 3. Setup the experiences presentation:

If you use SwiftUI, setup KetchUI.webPresentationItem as ketchView in View:
  
```swift
var body: some View {
    VStack {
        ...
    }
    .ketchView(model: $ketchUI.webPresentationItem)
}
```

If you use UIKit, present KetchUI as modal:

```swift
func presentKetchUI() {
    // 1. collect needed parameter
    let params: [KetchUI.ExperienceOption] = [
        .environment("production"),
        .language(code: "EN")
    ]

    // 2. reload ketch
    ketchUI.reload(with: params)
}
```

In UIKit you are responsible for KetchUI presenting/dismissal, so make sure you subscribe on Ketch events

```swift
ketchUI.eventListener = self
```  

```swift
extension ViewController: KetchEventListener {
    // present the Ketch View Controller
    func onShow() {
        guard let presentationItem = ketchUI.webPresentationItem else {
            return
        }
    
        present(presentationItem.viewController, animated: false)
    }
    
    // handle dssmiss
    func onDismiss() {
        dismiss(animated: false)
    }
    
    func onEnvironmentUpdated(environment: String?) { }
    func onRegionInfoUpdated(regionInfo: String?) { }
    func onJurisdictionUpdated(jurisdiction: String?) { }
    func onIdentitiesUpdated(identities: String?) { }
    func onConsentUpdated(consent: KetchSDK.ConsentStatus) { }
    func onError(description: String) { }
    func onCCPAUpdated(ccpaString: String?) { }
    func onTCFUpdated(tcfString: String?) { }
    func onGPPUpdated(gppString: String?) { }
}
```  

### Available Parameters

```swift
extension KetchUI {
    public enum ExperienceOption {
        
        /// Enables console logging by Ketch components
        case logLevel(LogLevel)
        
        /// Forces an experience to show
        case forceExperience(ExperienceToShow)
        
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
        
        public enum ExperienceToShow: String {
            case consent, preferences
        }
        
        public enum PreferencesTab: String, CaseIterable {
            case overviewTab, rightsTab, consentsTab, subscriptionsTab
        }
        
        public enum LogLevel: String, Codable {
            case trace, debug, info, warn, error
        }
    }
}
```

#### Updating KetchUI with new parameters

```swift
var params: [KetchUI.ExperienceOption] = [
                .region(code: "US"),
                .language(code: "EN"),
                .forceExperience(.consent),
                .jurisdiction(code: "default"),
                .environment("production")
            ]

ketchUI.reload(with: params)
```

### Event Listener
#### Available Events
```swift
public protocol KetchEventListener: AnyObject {
    func onShow()
    func onDismiss()
    func onEnvironmentUpdated(environment: String?)
    func onRegionInfoUpdated(regionInfo: String?)
    func onJurisdictionUpdated(jurisdiction: String?)
    func onIdentitiesUpdated(identities: String?)
    func onConsentUpdated(consent: KetchSDK.ConsentStatus)
    func onError(description: String)
    func onCCPAUpdated(ccpaString: String?)
    func onTCFUpdated(tcfString: String?)
    func onGPPUpdated(gppString: String?)
}
```

#### Subscribe on Events
```swift
ketchUI.eventListener = #{myEventListener}#
```

### Sample app

We provide a complete sample app to illustrate the integration: [here](https://github.com/ketch-sdk/ketch-samples/tree/main/ketch-ios/iOS%20Ketch%20SDK%20SwiftUI)
