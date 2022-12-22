# KetchSDK v2.0

Mobile SDK for iOS

Minimum iOS version supported 14.0

## Prerequisites
- Registered [Ketch organization account](https://app.ketch.com/settings/organization) 
- Configured [application property](https://app.ketch.com/deployment/applications) record


## Install SDK

### Cocoapods

KetchSTD deployed on JFrog Artifactory
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

3.To add an Artifactory Specs repo:

```
pod repo-art add ios "https://ketch.jfrog.io/artifactory/api/pods/ios"
```

4. Once the repository is added, to resolve pods from an Artifactory specs repo that you added, you must add the following to your Podfile:

```ruby
plugin 'cocoapods-art', :sources => [
    ios
]
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

-----------In order to use Ketch resources, import KetchSDK in your source file and initialize KetchSDK with shared instance:

### Step 2. Integrate calls for presentation of preference settings view (or view controller)

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

- Create ConsentConfig by .configure(:...) method and save it for future preferencesCenter launch. To keep the activity as configurable as the Ketch Smart Tag on the HTML page, it expects an organization code and property code to be passed in to it:

```swift
import AppTrackingTransparency
import AdSupport

...

private var config: ConsentConfig?

struct ContentView: View {

...

var body: some View {
    ...
    .onAppear {
        ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
            if case .authorized = authorizationStatus {
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier
                
                self?.config = ConsentConfig.configure(
                    orgCode: "#{your_org_code}#",
                    propertyName: "#{your_property}#",
                    advertisingIdentifier: advertisingId
                )
            }
        }
    }
}
```

- Show PreferenceCenter once you need to launch preferences setup:

```swift
...
.sheet(item: $configItem) { configItem in
    ConsentView(config: configItem)
}
```

- Full integration code with config:

```swift
import AppTrackingTransparency
import AdSupport

...

private var config: ConsentConfig?

struct ContentView: View {
    @State private var configItem: ConsentConfig?

    var body: some View {
        VStack {
            Button("Show Preference Center") {
                configItem = config
            }
        }
        .onAppear {
            ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
                if case .authorized = authorizationStatus {
                    let advertisingId = ASIdentifierManager.shared().advertisingIdentifier

                    config = ConsentConfig.configure(
                        orgCode: "#{your_org_code}#",
                        propertyName: "#{your_property}#",
                        advertisingIdentifier: advertisingId
                    )
                }
            }
        }
        .sheet(item: $configItem) { configItem in
            ConsentView(config: configItem)
        }
        ...
    }
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
