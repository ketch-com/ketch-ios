# KetchSDK
Mobile SDK for iOS

Minimum iOS version supported 13.0

## Install SDK

### Cocopads

Add KetchSDK to your podfile in project and run pod install:
```ruby
use_frameworks!

target 'Your_Target' do

  pod 'KetchSDK', :git =>'https://github.com/ketch-sdk/ketch-ios.git', :branch => 'lib'

end
```


## Setup

In order to use Ketch resources, import KetchSDK in your source file and initialize KetchSDK with shared instance:
```swift
import KetchSDK

...

let ketch = KetchSDK.shared
```

Or use methods from shared instance on demand:
```swift
import KetchSDK

...

KetchSDK
    .shared
    .config()
     ...
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
