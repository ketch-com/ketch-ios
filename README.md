# Ketch iOS SDK v3.0

Mobile SDK for iOS

Minimum iOS version supported: iOS 15.0

## Prerequisites

- Install and run [XCode](https://apps.apple.com/us/app/xcode/id497799835?mt=12) from the IOS App Store
  - When running for the first time, make sure to check the box for "iOS Simulator" so that you also get a mobile emulator to test on.
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

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Ketch iOS SDK as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

   ```swift
   dependencies: [
       .package(url: "https://github.com/ketch-com/ketch-ios.git", .upToNextMajor(from: "3.0.0"))
   ]
   ```

### Cocoapods

1. Add KetchUI as your dependency in your project, you must add the following to your Podfile:

   ```ruby
   target 'KetchSDK_Example' do

       pod 'KetchSDK/UI', '~> 3.0'

   end
   ```

2. And install as usual:

   ```
   pod install
   ```

   In case of necessity to trigger update of repository, you can run:

   ```
   pod update
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
            controllerCode: "#{your_controller}#",
            identities: [.custom("#{your_id}#")]
        )

        self.ketch = ketch
        ...
    }
    ```

- Setup instance of KetchUI with Ketch:

  ```swift
  ketchUI = KetchUI(ketch: ketch)
  ```

- Save these instances and that's it. Now Ketch is ready for work and presentation.

<details>
  <summary>Full setup example code using SwiftUI</summary>
  
Ketch and KetchUI instances setup

```swift
import SwiftUI
import KetchSDK

class ContentView: View {
    @ObservedObject var ketchUI: KetchUI

    init() {
        let ketch = KetchSDK.create(
            organizationCode: "#{your_org_code}#",
            propertyCode: "#{your_property}#",
            environmentCode: "#{your_environment}#",
            controllerCode: "#{your_controller}#",
            identities: [.idfa(advertisingIdentifier.uuidString)]
        )

        ketchUI = KetchUI(ketch: ketch)
    }

    ...
}
```

- Setup UI experiences presentation:

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

  </details>

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
