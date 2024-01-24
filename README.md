# Ketch iOS SDK v3.0

Mobile SDK for iOS

Minimum iOS version supported: iOS 15.0

## Prerequisites
- Registered [Ketch organization account](https://app.ketch.com/settings/organization) 
- Configured [application property](https://app.ketch.com/deployment/applications) record
- latest [XCode](https://developer.apple.com/xcode/) 
- [CocoaPods](https://formulae.brew.sh/formula/cocoapods) installed

## Running the Sample app

### Step 1. Clone the repository and install dependencies

```
git clone git@github.com:ketch-com/ketch-ios.git
cd ketch-ios/Example
git checkout version_3
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

1. Add KetchUI as your dependency in your project, you must add the following to your Podfile:
    
    ```ruby
    target 'KetchSDK_Example' do

        pod 'KetchSDK/UI',
        :git => 'git@github.com:ketch-com/ketch-ios.git',
        :branch => 'version_3'

    end
    ```

2. And install as usual:

    ```
    pod install
    ```
    
    In case of necessity to trigger update of repository you can run:
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

- Save these instances and that's it. Now Ketch ready for work and presentation.

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

