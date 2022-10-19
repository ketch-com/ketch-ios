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


## Requests

The next methods send requests to the back-end

### Get BootstrapConfiguration
Retrieves bootstrap configuration data.
- Parameter `organization` : organization code
- Parameter `property` : property code
- Parameter `result : (Result<BootstrapConfiguration>) -> Unit` - callback that returns `Result` with `BootstrapConfiguration` if successful and with an error if request or its handling failed

```kotlin
ketch.getBootstrapConfiguration(
    organization = <organization_code>,
    property = <property_code>
) {
    when (result) {
        is Result.Loading -> // handle loading
        is Result.Success -> // handle success
        is Result.Error -> // handle error
    }
}
```

### Get FullConfiguration 1
Retrieves full organization configuration data.
- Parameter `organization` : organization code
- Parameter `property` : property code
- Parameter `result : (Result<FullConfiguration>) -> Unit` - callback that returns `Result` with `FullConfiguration` if successful and with an error if request or its handling failed

```kotlin
ketch.getBootstrapConfiguration(
    organization = <organization_code>,
    property = <property_code>,
) {
    when (result) {
        is Result.Loading -> // handle loading
        is Result.Success -> // handle success
        is Result.Error -> // handle error
    }
}
```

### Get FullConfiguration 2
Retrieves full organization configuration data.
- Parameter `organization` : organization code
- Parameter `property` : property code
- Parameter `environment` : environment code
- Parameter `jurisdiction` : jurisdiction code
- Parameter `result : (Result<FullConfiguration>) -> Unit` - callback that returns `Result` with `FullConfiguration` if successful and with an error if request or its handling failed

```kotlin
ketch.getFullConfiguration(
    organization = <organization_code>,
    property = <property_code>,
    environment = <environment_code>,
    jurisdiction = <jurisdiction_code>
) {
    when (result) {
        is Result.Loading -> // handle loading
        is Result.Success -> // handle success
        is Result.Error -> // handle error
    }
}
```

### Get Consent
Retrieves currently set consent status.
- Parameter `organization` : organization code
- Parameter `controller` : controller code
- Parameter `property` : property code
- Parameter `environment` : environment code
- Parameter `jurisdiction` : jurisdiction code
- Parameter `identities` : map of identity code and value
- Parameter `purposes` : map of purpose code and PurposeLegalBasis
- Parameter `result : (Result<Consent>) -> Unit` - callback that returns `Result` with `Consent` if successful and with an error if request or its handling failed

```kotlin
val identities = mapOf<String, String>(
    ...
)

val purposes = mapOf<String, PurposeLegalBasis>(
    ...
)

fun getConsent(
    organization = <organization_code>,
    controller = <controller_code>,
    property = <property_code>,
    environment = <environment_code>,
    jurisdiction = <jurisdiction_code>,
    identities = identities,
    purposes = purposes
) {
    when (result) {
        is Result.Loading -> // handle loading
        is Result.Success -> // handle success
        is Result.Error -> // handle error
    }
}
```

### Set Consent
Sends a request for updating consent status.
- Parameter `organization` : organization code
- Parameter `controller` : controller code
- Parameter `property` : property code
- Parameter `environment` : environment code
- Parameter `jurisdiction` : jurisdiction code
- Parameter `collectedAt` : the current time
- Parameter `identities` : map of identity code and value
- Parameter `purposes` : map of purpose code and PurposeLegalBasis
- Parameter `vendors` : list of vendors
- Parameter `migrationOption` : migration option. Can be MIGRATE_DEFAULT, MIGRATE_NEVER, MIGRATE_FROM_ALLOW, MIGRATE_FROM_DENY, MIGRATE_ALWAYS 
- Parameter `result : (Result<Unit>) -> Unit` - callback that returns `Result`, it can be Successful or Error with an error field if request or its handling failed

```kotlin
val identities = mapOf<String, String>(
    ...
)

val purposes = mapOf<String, PurposeLegalBasis>(
    ...
)

val vendors = listOf<String>(
        
)

fun updateConsent(
    organization = <organization_code>,
    controller = <controller_code>,
    property = <property_code>,
    environment = <environment_code>,
    jurisdiction = <jurisdiction_code>,
    collectedAt = System.currentTimeMillis(),
    identities = identities,
    purposes = purposes,
    vandors = vendors,
    migrationOption = MigrationOption.MIGRATE_DEFAULT
) {
    when (result) {
        is Result.Loading -> // handle loading
        is Result.Success -> // handle success
        is Result.Error -> // handle error
    }
}
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
- Parameter `result : (Result<Unit>) -> Unit` - callback that returns `Result`, it can be Successful or Error with an error field if request or its handling failed

```kotlin
val identities = mapOf<String, String>(
    ...
)

val user = User(
    email = <user email>,
    first = <first name>,
    last = <last name>,
    country = <country>,
    stateRegion = <state>,
    description = <description>,
    phone = <phone>,
    postalCode = <postal code>,
    addressLine1 = <address line 1>,
    addressLine2 = <address line 2>,        
)

fun invokeRights(
    organization = <organization_code>,
    controller = <controller_code>,
    property = <property_code>,
    environment = <environment_code>,
    jurisdiction = <jurisdiction_code>,
    invokedAt = System.currentTimeMillis(),
    identities = identities,
    right = <right code>,
    user = user,
) {
    when (result) {
        is Result.Loading -> // handle loading
        is Result.Success -> // handle success
        is Result.Error -> // handle error
    }
}
```
