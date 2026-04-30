# Ketch iOS SDK Sample App

## Prerequisites

- Install [XCode](https://apps.apple.com/us/app/xcode/id497799835?mt=12) and a iOS emulator

## Quick Guide

### Step 1. Clone the repository and install dependencies

```
git clone git@github.com:ketch-sdk/ketch-samples.git
cd "ketch-ios/sdk/ketch-ios-sample"
```

### Step 2. Run the app in XCode

Open the **project workspace** `KetchSDK.xcodeproj` in the XCode.

Click Run to build and run the app on the simulator or a physical device.

### (Optional) Step 3. Use your own Ketch organization and property

By default, this sample application is connected to an existing Ketch organization with preconfigured settings.

To use your own organization and property, modify the `init()` function within
[`ContentView.swift`](./KetchSDK/ContentView.swift#L67-L75) as follows:

```swift
// Create the KetchSDK object
let ketch = KetchSDK.create(
    organizationCode: "your_organization_code",
    propertyCode: "your_property_code",
    environmentCode: "your_environment_code",  // e.g. "production"
    identities: [
        // e.g. Ketch.Identity(key: "idfa", value: "00000000-0000-0000-0000-000000000000")
        Ketch.Identity(key: "your_identity_name", value: "your_identity_value")
    ]
)
```
