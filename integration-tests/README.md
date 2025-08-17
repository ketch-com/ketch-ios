# Ketch iOS SDK Integration Tests

This directory hosts the automated integration-test suite for the **Ketch iOS SDK**.  
The suite contains:

* **Sample App** – a minimal SwiftUI application that embeds the **KetchSDK** package and exposes all major APIs through buttons and live status labels.  
* **UI Tests** – XCUITest cases that drive the sample app end-to-end, interacting with the embedded `WKWebView` to validate consent flows exactly as our Android tests do.

---

## Directory Structure

```
integration-tests/
├── project.yml            # XcodeGen definition for the test workspace
├── App/                   # Sample application source
│   ├── KetchIntegrationApp.swift
│   ├── ContentView.swift
│   ├── IntegrationViewModel.swift
│   └── Info.plist
├── UITests/               # XCUITest bundle source
│   └── KetchIntegrationUITests.swift
├── run-integration-tests.sh
└── README.md              # (this file)
```

`project.yml` is converted into an `.xcodeproj` at test time; **no project files are committed**.

---

## Running the Tests

### 1  Prerequisites

* macOS with **Xcode 15** (or newer) installed
* **iOS Simulator** available (default: *iPhone 15, iOS 17*)
* **XcodeGen** – used to generate the project  
  Install once:

```bash
brew install xcodegen        # or `mint install yonaskolb/XcodeGen`
```

### 2  Generate the project

```bash
cd integration-tests
xcodegen generate            # creates KetchIntegrationTests.xcodeproj
```

### 3  Run from Xcode (interactive)

1. Open `KetchIntegrationTests.xcodeproj`.
2. Select the **KetchIntegrationTestsApp** scheme.
3. Choose a simulator (e.g., *iPhone 15*).
4. ⌘U to run all tests.

### 4  Run from command line (CI-friendly)

```bash
./run-integration-tests.sh
```

The script is a thin wrapper around:

```bash
xcodebuild \
  -project KetchIntegrationTests.xcodeproj \
  -scheme KetchIntegrationTestsApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test | xcpretty
```

---

## Test Coverage

Current UI tests verify:

* **SDK Initialization** – app starts and displays initial state.
* **Configuration & Consent Loading** – `load()` triggers config and consent callbacks.
* **Dialog Presentation** – `showConsent()` and `showPreferences()` display the proper web experiences and DOM elements (`ketch-consent-banner`, `ketch-preferences`).
* **User Interaction** – tests click banner buttons (opt-out / opt-in) via injected JavaScript and assert resulting events and state changes.
* **State Display** – labels for environment, consent, TCF, US Privacy, GPP update as expected.
* **UI Sanity** – all action buttons are visible and tappable.

---

## Sample App Features

Buttons (all have accessibility identifiers matching Android IDs):

* Load, Show Consent, Show Preferences  
* Set Language (EN), Set Jurisdiction (US), Set Region (California)

Labels:

* Status, Environment, Consent, US Privacy, TCF, GPP  
* Hidden **Test Actions** section used by UITests for WebView JS validation.

---

## Configuration

Default test configuration is hard-coded in `IntegrationViewModel.swift`.

```
orgCode      = ketch_samples
propertyCode = ios
environment  = production
```

Expanding to additional environments is trivial: pass extra `ExperienceOption` values in `ketchUI.reload(...)` (e.g., `.environment("staging")`, `.language(code: "FR")`, etc.).

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| **Simulator “iPhone 15” not found** | Open Xcode → Settings → Platforms → install the desired iOS runtime or edit `run-integration-tests.sh` to use an available simulator (`xcrun simctl list devices`). |
| **`xcodegen` command not found** | `brew install xcodegen` or add to PATH via Mint. |
| **Network / CDN errors** | Ensure the machine has internet access to `global.ketchcdn.com` and `cdn.ketchjs.com`; corporate VPNs / proxies can block downloads. |
| **`WKWebView` fails to load content in tests** | Reset simulator content & settings, then rerun. |

---

Happy testing!  
If you hit issues not covered here, open a GitHub issue or ping the SDK team.  
