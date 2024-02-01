# Ketch Mobile SDK for iOS

The Ketch Mobile SDK allows to manage and collect a visitor's consent preferences for an organization on the mobile platforms.

## Requirements

SDK supports iOS version 15.0 and above.
The minimum required version of Xcode is 15.0. 
The minimum required version of Swift is 5.5.

The use of the Mobile SDK requires an [Ketch organization account](https://app.ketch.com/settings/organization) 
with the [application property](https://app.ketch.com/deployment/applications)  configured.

## Quick Start

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Ketch iOS SDK as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

   ```swift
   dependencies: [
       .package(url: "https://github.com/ketch-com/ketch-ios.git", .upToNextMajor(from: "3.0.0"))
   ]
   ```
## Setup

### Step 1. Implement Ketch and KetchUI instances setup

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

### Step 2.  Setup instance of KetchUI with Ketch:

```swift
ketchUI = KetchUI(ketch: ketch)
```

Save these instances and that's it. Now Ketch is ready for work and presentation.

### Step 3.  Setup UI experiences presentation:

If you using SwiftUI, please setup presentation KetchUI.webPresentationItem as ketchView in View that you need:
  
```swift
var body: some View {
    VStack {
        ...
    }
    .ketchView(model: $ketchUI.webPresentationItem)
}
```

Experiences will be shown automatically by corresponding call.

<details>
<summary>How to override Ketch view size</summary>

You need to inherit the `KetchUI.PresentationSizeFactory` class.

In your subclass you can override:

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

You can find a sample app [here](https://github.com/ketch-sdk/ketch-samples/tree/main/ketch-ios/iOS%20Ketch%20SDK%20SwiftUI)
