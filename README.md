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
    ...

    var ketch: Ketch?
    var ketchUI: KetchUI?

    ...

    private func setupKetch(advertisingIdentifier: UUID) {
        let ketch = KetchSDK.create(
            organizationCode: "#{your_org_code}#",
            propertyCode: "#{your_property}#",
            environmentCode: "#{your_environment}#",
            identities: [.custom("#{your_id}#")]
        )

        self.ketch = ketch
        ...
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

### Step 4. Invoke the view:
TBD

<details>
<summary>How to override Ketch view size</summary>

Inherit the `KetchUI.PresentationSizeFactory` class and override:

```swift
open func calculateModalSize(
            horizontalPosition: KetchUI.PresentationConfig.HPosition,
            verticalPosititon: KetchUI.PresentationConfig.VPosition,
            screenSize: CGSize
        ) -> CGSize
```
and

```swift
open func calculateBannerSize(
            horizontalPosition: KetchUI.PresentationConfig.HPosition,
            verticalPosititon: KetchUI.PresentationConfig.VPosition,
            screenSize: CGSize
        ) -> CGSize
```

Set your presentation subclass to the KetchUI instance:

`ketchUI.sizeFactory = ExampleSizeFactory()`
  
</details>

### Sample app

We provide a complete sample app to illustrate the integration: [here](https://github.com/ketch-sdk/ketch-samples/tree/main/ketch-ios/iOS%20Ketch%20SDK%20SwiftUI)
