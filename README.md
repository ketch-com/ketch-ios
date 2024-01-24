# Ketch iOS SDK v3.0

Mobile SDK for iOS

Minimum iOS version supported: iOS 14.0

## Prerequisites
- Registered [Ketch organization account](https://app.ketch.com/settings/organization) 
- Configured [application property](https://app.ketch.com/deployment/applications) record

## Running the Sample app

### Step 1. Clone the repository and install dependencies

```
git clone git@github.com:ketch-com/ketch-ios.git
cd ketch-ios/Example
pod install
```

### Step 2. Run the app in XCode

Open the project workspace `Example/KetchSDK.xcworkspace` in the XCode.

Add your organization code, property code to
`ketch-ios/Example/KetchSDK/ContentView.swift`:

```swift
organizationCode: "???????????????????",
propertyCode: "???????????????????",
```

Click Run to build and run the app on the simulator or a device.


## Install SDK

### Cocoapods

KetchSDK deployed on JFrog Artifactory
In order to use CocoaPods with Artifactory you will need to install the ['cocoapods-art'](https://github.com/jfrog/cocoapods-art) plugin.

1. To install cocoapods-art run the following command:

    ```
    gem install cocoapods-art
    ```

2. repo-art uses authentication as specified in your standard netrc file:

    ```
    open ~/.netrc
    ```

    netrc file:

    ```
    machine ketch.jfrog.io
    login <#YOUR LOGIN#>
    password <#YOUR PASSWORD#>
    ```

3. To add an Artifactory Specs repo:

    ```
    pod repo-art add ios "https://ketch.jfrog.io/artifactory/api/pods/ios"
    ```

4. Once the repository is added, to resolve pods from an Artifactory specs repo that you added, you must add the following to your Podfile:

    ```ruby
    plugin 'cocoapods-art', :sources => [
        ios
    ]
    
    pod 'KetchSDK'
    ```
    
    Or you can specify which modules you need.
    SDK includes Core, CCPA, TCF and UI modules.
    Core - Base SDK library. It includes all necessary request to work with our backend
    CCPA and TCF - Specific protocol plugins. 
    UI - UI Module. It includes all predefined visual dialogs.
    
    ```ruby
    pod 'KetchSDK/Core'
    pod 'KetchSDK/CCPA'
    pod 'KetchSDK/TCF'
    pod 'KetchSDK/UI'
    ```

5. Then you can use install as usual:

    ```
    pod install
    ```
    
    In case of necessity to trigger update of repository you can run:
    ```
    pod repo-art update ios  
    ```


## Setup

### Step 1. Add Info.plist privacy tracking request

Define `Info.plist` string for tracking allowance request with key 
`Privacy - Tracking Usage Description` (`NSUserTrackingUsageDescription`) 
that describes wanted purpose, e.g. "Please indicate whether you consent to our collection and use 
of your data in order to perform the operation(s) you’ve requested."


### Step 2. Implement Ketch and KetchUI instances setup

- Request permission for application tracking using `requestTrackingAuthorization` from `AppTrackingTransparency.ATTrackingManager`:

    ```swift
    import AppTrackingTransparency

    ...

    ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
        if case .authorized = authorizationStatus {
            ...
        }
    }
    ```

- Retrieve `advertisingIdentifier` from `AdSupport.ASIdentifierManager`:

    ```swift
    import AppTrackingTransparency
    import AdSupport

    ...
        
    ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
        if case .authorized = authorizationStatus {
            let advertisingId = ASIdentifierManager.shared().advertisingIdentifier
            
            ...
        }
    }
    ```

- Once you will have advertisingIdentifier, create instance of Ketch class that will process all necessary actions by using KetchSDK.create(...) with values you setup on [https://app.ketch.com/settings](https://app.ketch.com/settings). And instance of KetchUI to handle UI experiences presentation.


    ```swift
    import AppTrackingTransparency
    import AdSupport

    ...

    var ketch: Ketch?
    var ketchUI: KetchUI?

    ...

    func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
            if case .authorized = authorizationStatus {
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier
                DispatchQueue.main.async {
                    self.setupKetch(advertisingIdentifier: advertisingId)
                }
            } else if case .denied = authorizationStatus {
                // authorizationDenied
            }
        }
    }

    private func setupKetch(advertisingIdentifier: UUID) {
        let ketch = KetchSDK.create(
            organizationCode: "#{your_org_code}#",
            propertyCode: "#{your_property}#",
            environmentCode: "#{your_environment}#",
            controllerCode: "#{your_controller}#",
            identities: [.idfa(advertisingIdentifier.uuidString)]
        )
        
        self.ketch = ketch
        ...

    }
    ```

- Setup instance of Ketch with protocol Plugin you want to process consents:

    ```swift
    ketch.add(plugins: [TCF(), CCPA()])
    ```
    
    KetchSDK contains implemented versions of protocols Plugin:
    - [IAB TCFv2](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md)
    - [CCPA](https://github.com/InteractiveAdvertisingBureau/USPrivacy/blob/master/CCPA/USP%20API.md)
    
     Also you can implement your own Plugin by confirming PolicyPlugin protocol.
     
     
- Setup instance of KetchUI with Ketch:

    ```swift
    ketchUI = KetchUI(ketch: ketch)
    ```

- Save these instances and that's it. Now Ketch ready for work and presentation.

<details>
  <summary>Full setup example code using SwiftUI</summary>
  
Ketch and KetchUI instances setup

```swift
import SwiftUI
import KetchSDK
import AdSupport
import AppTrackingTransparency

class ContentViewModel: ObservableObject {
    @Published var ketch: Ketch?
    @Published var ketchUI: KetchUI?
    @Published var authorizationDenied = false

    init() { }

    func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
            if case .authorized = authorizationStatus {
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier
                DispatchQueue.main.async {
                    self.setupKetch(advertisingIdentifier: advertisingId)
                }
            } else if case .denied = authorizationStatus {
                self.authorizationDenied = true
            }
        }
    }

    private func setupKetch(advertisingIdentifier: UUID) {
        let ketch = KetchSDK.create(
            organizationCode: "#{your_org_code}#",
            propertyCode: "#{your_property}#",
            environmentCode: "#{your_environment}#",
            controllerCode: "#{your_controller}#",
            identities: [.idfa(advertisingIdentifier.uuidString)]
        )

        ketch.add(plugins: [TCF(), CCPA()])

        self.ketch = ketch
        ketchUI = KetchUI(ketch: ketch)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            ...
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                //  Delay after SwiftUI view appearing is required for alert presenting, otherwise it will not be shown
                viewModel.requestTrackingAuthorization()
            }
        }
        .alert(isPresented: $viewModel.authorizationDenied) {
            Alert(
                title: Text("Tracking Authorization Denied by app settings"),
                message: Text("Please allow tracking in Settings -> Privacy -> Tracking"),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(
                    Text("Edit preferences"),
                    action: {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            )
        }
    }
}
```
</details>


<details>
  <summary>Full setup example code using UIKit</summary>
  
Ketch and KetchUI instances setup

```swift

import UIKit
import Combine
import KetchSDK
import AdSupport
import AppTrackingTransparency
import SwiftUI

class ViewController: UIViewController {
    private var ketch: Ketch?
    private var ketchUI: KetchUI?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        ATTrackingManager.requestTrackingAuthorization { [weak self] authorizationStatus in
            if case .authorized = authorizationStatus {
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier

                DispatchQueue.main.async {
                    self?.setupKetch(advertisingIdentifier: advertisingId)
                }
            } else if case .denied = authorizationStatus {
                let alert = UIAlertController(
                    title: "Tracking Authorization Denied by app settings",
                    message: "Please allow tracking in Settings -> Privacy -> Tracking",
                    preferredStyle: .alert
                )

                alert.addAction(
                    UIAlertAction(title: "Cancel", style: .cancel)
                )

                alert.addAction(
                    UIAlertAction(title: "Edit preferences", style: .default) { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )

                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func setupKetch(advertisingIdentifier: UUID) {
        let ketch = KetchSDK.create(
            organizationCode: "#{your_org_code}#",
            propertyCode: "#{your_property}#",
            environmentCode: "#{your_environment}#",
            controllerCode: "#{your_controller}#",
            identities: [.idfa(advertisingIdentifier.uuidString)]
        )

        ketch.add(plugins: [TCF(), CCPA()])

        self.ketch = ketch
        ketchUI = KetchUI(ketch: ketch)
    }
}
```
    
</details>


### Step 3. Call Ketch workflow methods

- Load Configuration:
    For initial fetching Ketch config from the platform
    
    ```swift
    ketch.loadConfiguration()
    ```
    
    Also you can specify jurisdiction for config call:
    ```swift
    ketch.loadConfiguration(jurisdiction: Jurisdiction.GDPR)
    ketch.loadConfiguration(jurisdiction: Jurisdiction.CCPA)
    ```
    
    After configuration load Ketch able to run invokeRights, loadConsent, and updateConsent:

    ```swift
    if let config = ketch.configuration {
        ketch.invokeRights(right: <#right#>, user: <#user#>)
        ketch.loadConsent()
        ketch.updateConsent(purposes: <#purposes#>, vendors: <#vendors#>)
    }
    ```
    
- loadConsent:
    Loading existing consents from the platform for current identity.
    ```swift
    ketch.loadConsent()
    ```
    
    After request Consents stored internally in Ketch instance and available from corresponding publishers in Ketch and KetchUI
    
- invokeRights:
    To send request to the platform for user rights invocation
    ```swift
    let user = KetchSDK.InvokeRightConfig.User(
        email: "user@email.com", // required
        first: "FirstName", // required
        last: "LastName", // required
        country: nil,
        stateRegion: nil,
        description: nil,
        phone: nil,
        postalCode: nil,
        addressLine1: nil,
        addressLine2: nil
    )
    
    let right = config.rights?.first // any available right in config
    
    if let config = ketch.configuration {
        ketch.invokeRights(right: right, user: user)
    }   
    ```
    
- updateConsent:
    Send consent status to the platform
    
    ```swift
        let purposes = config.purposes?
            .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]()) { result, purpose in
                result[purpose.code] = .init(allowed: true, legalBasisCode: purpose.legalBasisCode)
            }

        let vendors = config.vendors?.map(\.id)

        ketch.updateConsent(purposes: purposes, vendors: vendors)
    ```
    
### Step 4. Call KetchUI workflow methods
Once you setup Ketch, KetchUI, requested config ( ketch.loadConfiguration() ) and consentStatus ( ketch.loadConsent() )
You can launch presentation of user experiences of type:

- Banner
- Modal
- JIT
- Preference

Or you can set automatic presentation of default experience from configuration and KethUI will present in automatically once config ( ketch.loadConfiguration() ) and consentStatus ( ketch.loadConsent() ) loaded.
    
```swift
ketchUI.showDialogsIfNeeded = true
```

- Setup UI experiences presentation:

    If you using SwiftUI, please setup presentation KetchUI.presentationItem.content as fullScreenCover in View that you need:
    ```swift
    VStack {
        ...
    }
    .fullScreenCover(item: $ketchUI.presentationItem, content: \.content)
    ```
    
    If you using SwiftUI, please setup presentation KetchUI.presentationItem.viewController ViewController that you need:
    ```swift
    ketchUI.$presentationItem
        .receive(on: DispatchQueue.main)
        .sink { presentationItem in
            guard let presentationItem else { return }

            self.present(presentationItem.viewController, animated: true)
        }
        .store(in: &subscriptions)
    ```
    
    Experiences will be shown automatically by corresponding call.
    
- Show Banner
    ```swift
    ketchUI.showBanner()
    ```
    
- Show Modal
    ```swift
    ketchUI.showModal()
    ```
    
- Show Preference
    ```swift
    ketchUI.showPreference()
    ```
    
- Show JIT (Just in Time)
    JIT is specific permission asking experience. So than we need to pass specific Purpose from config into this call:

    ```swift
    if let purpose = ketchUI.configuration.purposes?.first { // any available purpose in config
        ketchUI.showJIT(purpose: purpose)
    }
    ```

## Direct API calls using Ketch

<details>
  <summary>Requests using Combine</summary>
  
The next methods send requests to the back-end

### Get Configuration
Retrieves configuration data.
- Parameter `organization` : organization code
- Parameter `property` : property code
- Returns: Publisher of organization configuration request result.

```swift
KetchSDK
    .shared
    .config(
        organization: <#organization_code#>,
        property: <#property_code#>
    )
    .sink { completion in
        switch completion {
        case .failure(let error): // handle error
        case .finished: // handle request finish
        }
    } receiveValue: { config in
        // handle config
    }
    .store(in: &subscriptions)
```

### Get Consent
Retrieves currently set consent status.
- Parameter `organizationCode` : organization code
- Parameter `controllerCode` : controller code
- Parameter `propertyCode` : property code
- Parameter `environmentCode` : environment code
- Parameter `jurisdictionCode` : jurisdiction code
- Parameter `identities` : [String: String] map of identity code and value "idfa" is preferred identity code for iOS clients.
- Parameter `purposes` : [String: PurposeLegalBasis] map of purpose code and PurposeLegalBasis
- Returns: AnyPublisher<ConsentStatus, KetchError> Publisher of get consent request result.

```swift
KetchSDK
    .shared
    .getConsent(
        organizationCode: <#organization_code#>,
        controllerCode: <#controller_code#>,
        propertyCode: <#property_code#>,
        environmentCode: <#environment_code#>,
        jurisdictionCode: <#jurisdiction_code#>,
        identities: [ <#identity_code#> : <#identity_value#>],
        purposes: [
            <#purpose_code1#>: .init(legalBasisCode: "disclosure"),
            <#purpose_code2#>: .init(legalBasisCode: "consent_optin")
        ]
    )
    .sink { completion in
        switch completion {
        case .failure(let error): // handle error
        case .finished: // handle request finish
        }
    } receiveValue: { config in
        // handle config
    }
    .store(in: &subscriptions)
```

### Set Consent
Sends a request for updating consent status.
- Parameter `organizationCode` : organization code
- Parameter `controllerCode` : controller code
- Parameter `propertyCode` : property code
- Parameter `environmentCode` : environment code
- Parameter `identities` : [String: String] map of identity code and value "idfa" is preferred identity code for iOS clients.
- Parameter `collectedAt` : the current timestamp
- Parameter `jurisdictionCode` : jurisdiction code
- Parameter `migrationOption` : migration option enum
- Parameter `purposes` : [String: PurposeLegalBasis] map of purpose code and PurposeLegalBasis
- Parameter `vendors` : list of vendors
- Returns: AnyPublisher<Void, KetchError> Publisher of set consent request result.

```swift
KetchSDK
    .shared
    .setConsent(
        organizationCode: <#organization_code#>,
        controllerCode: <#controller_code#>,
        propertyCode: <#property_code#>,
        environmentCode: <#environment_code#>,
        identities: [ <#identity_code#> : <#identity_value#>],
        collectedAt: <#timestamp#>,
        jurisdictionCode: <#jurisdiction_code#>,
        migrationOption: <#migration_option#>,
        purposes: [
            <#purpose_code1#>: .init(allowed: true, legalBasisCode: "disclosure"),
            <#purpose_code2#>: .init(allowed: true, legalBasisCode: "consent_optin")
        ],
        vendors: [
            <#vendor_code1#>,
            <#vendor_code2#>
        ]
    )
    .sink { completion in
        switch completion {
        case .failure(let error): // handle error
        case .finished: // handle request finish
        }
    } receiveValue: { _ in
        // handle result
    }
    .store(in: &subscriptions)
```

### Invoke Rights
Invokes the specified rights.
- Parameter `organization` : organization code
- Parameter `controller` : controller code
- Parameter `property` : property code
- Parameter `environment` : environment code
- Parameter `jurisdiction` : jurisdiction code
- Parameter `invokedAt` : the current time
- Parameter `identities` : map of identity code and value
- Parameter `right` : right code
- Parameter `user` : current user object
- Returns: AnyPublisher<Void, KetchError> Publisher of Invoke Rights request result.

```swift
KetchSDK
    .shared
    .invokeRights(
        organizationCode: <#organization_code#>,
        controllerCode: <#controller_code#>,
        propertyCode: <#property_code#>,
        environmentCode: <#environment_code#>,
        identities: [ <#identity_code#> : <#identity_value#>],
        collectedAt: <#timestamp#>,
        jurisdictionCode: <#jurisdiction_code#>,
        rightCode: <#right_code#>,
        user: .init(
            email: <#email#>,
            first: <#First_Name#>,
            last: <#Last_Name#>,
            country: <#country#>,
            stateRegion: <#stateRegion#>,
            description: <#description#>,
            phone: <#phone#>,
            postalCode: <#postalCode#>,
            addressLine1: <#addressLine1#>,
            addressLine2: <#addressLine2#>
        )
    )
    .sink { completion in
        switch completion {
        case .failure(let error): // handle error
        case .finished: // handle request finish
        }
    } receiveValue: { _ in
        // handle result
    }
    .store(in: &subscriptions)
```
  
</details>

<details>
  <summary>Requests using Result callback closures</summary>
  
The next methods send requests to the back-end

### Get Configuration
Retrieves configuration data.
- Parameter `organization` : organization code
- Parameter `property` : property code
- Parameter `completion` : Request `Result<Configuration, KetchError>` callback

```swift
KetchSDK
    .shared
    .fetchConfig(
        organization: <#organization_code#>,
        property: <#property_code#>
    ) { result in
        switch result {
        case .failure(let error): // handle error
        case .success(let config): // handle config
        }
    }
```

### Get Consent
Retrieves currently set consent status. For fetchGetConsent needs to initialize ConsentConfig struct.

ConsentConfig:
- Parameter `organizationCode` : organization code
- Parameter `controllerCode` : controller code
- Parameter `propertyCode` : property code
- Parameter `environmentCode` : environment code
- Parameter `jurisdictionCode` : jurisdiction code
- Parameter `identities` : [String: String] map of identity code and value "idfa" is preferred identity code for iOS clients.
- Parameter `purposes` : [String: PurposeLegalBasis] map of purpose code and PurposeLegalBasis

FetchGetConsent:
- Parameter `consentConfig` : ConsentConfig
- Parameter `completion`: Result<ConsentStatus, KetchError> Publisher of get consent request result.

```swift
let config = KetchSDK.ConsentConfig(
    organizationCode: <#organization_code#>,
    controllerCode: <#controller_code#>,
    propertyCode: <#property_code#>,
    environmentCode: <#environment_code#>,
    jurisdictionCode: <#jurisdiction_code#>,
    identities: [ <#identity_code#> : <#identity_value#>],
    purposes: [
        <#purpose_code1#>: .init(legalBasisCode: "disclosure"),
        <#purpose_code2#>: .init(legalBasisCode: "consent_optin")
    ]
)

KetchSDK
    .shared
    .fetchGetConsent(
        consentConfig: config
    ) { result in
        switch result {
        case .failure(let error): break
        case .success(let config): break
        }
    }
```

### Set Consent
Sends a request for updating consent status. For fetchSetConsent needs to initialize ConsentUpdate struct.

ConsentUpdate:
- Parameter `organizationCode` : organization code
- Parameter `controllerCode` : controller code
- Parameter `propertyCode` : property code
- Parameter `environmentCode` : environment code
- Parameter `identities` : [String: String] map of identity code and value "idfa" is preferred identity code for iOS clients.
- Parameter `collectedAt` : the current timestamp
- Parameter `jurisdictionCode` : jurisdiction code
- Parameter `migrationOption` : migration option enum
- Parameter `purposes` : [String: PurposeLegalBasis] map of purpose code and PurposeLegalBasis
- Parameter `vendors` : list of vendors

FetchSetConsent:
- Parameter `consentUpdate` : ConsentUpdate
- Parameter `completion`: Result<Void, KetchError> Publisher of set consent request result.

```swift
let update = KetchSDK.ConsentUpdate(
    organizationCode: <#organization_code#>,
    controllerCode: <#controller_code#>,
    propertyCode: <#property_code#>,
    environmentCode: <#environment_code#>,
    identities: [ <#identity_code#> : <#identity_value#>],
    collectedAt: <#timestamp#>,
    jurisdictionCode: <#jurisdiction_code#>,
    migrationOption: <#migration_option#>,
    purposes: [
        <#purpose_code1#>: .init(allowed: true, legalBasisCode: "disclosure"),
        <#purpose_code2#>: .init(allowed: true, legalBasisCode: "consent_optin")
    ],
    vendors: [
        <#vendor_code1#>,
        <#vendor_code2#>
    ]
)

KetchSDK
    .shared
    .fetchSetConsent(consentUpdate: update) { result in
        switch result {
        case .failure(let error): // handle error
        case .success: // handle success
        }
    }
```

### Invoke Rights
Invokes the specified rights. For fetchInvokeRights needs to initialize InvokeRightConfig struct.

InvokeRightConfig:
- Parameter `organization` : organization code
- Parameter `controller` : controller code
- Parameter `property` : property code
- Parameter `environment` : environment code
- Parameter `jurisdiction` : jurisdiction code
- Parameter `invokedAt` : the current time
- Parameter `identities` : map of identity code and value
- Parameter `right` : right code
- Parameter `user` : current user object

FetchInvokeRights:
- Parameter `config` : InvokeRightConfig
- Parameter `completion`: Result<Void, KetchError> Publisher of Invoke Rights request result.

```swift
let rightsConfig = KetchSDK.InvokeRightConfig(
    organizationCode: <#organization_code#>,
    controllerCode: <#controller_code#>,
    propertyCode: <#property_code#>,
    environmentCode: <#environment_code#>,
    identities: [ <#identity_code#> : <#identity_value#>],
    collectedAt: <#timestamp#>,
    jurisdictionCode: <#jurisdiction_code#>,
    rightCode: <#right_code#>,
    user: .init(
        email: <#email#>,
        first: <#First_Name#>,
        last: <#Last_Name#>,
        country: <#country#>,
        stateRegion: <#stateRegion#>,
        description: <#description#>,
        phone: <#phone#>,
        postalCode: <#postalCode#>,
        addressLine1: <#addressLine1#>,
        addressLine2: <#addressLine2#>
    )
)

KetchSDK
    .shared
    .fetchInvokeRights(
        config: rightsConfig
    ) { result in
        switch result {
        case .failure(let error): // handle error
        case .success: // handle success
        }
    }
```
  
</details>
