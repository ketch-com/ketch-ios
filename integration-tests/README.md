# Ketch iOS SDK Integration Tests

This directory hosts the automated integration-test suite for the **Ketch iOS SDK**.  
The suite contains:

* **Sample App** – a minimal SwiftUI application that embeds the **KetchSDK** package and exposes all major APIs through buttons and live status labels.  
* **UI Tests** – XCUITest cases that drive the sample app end-to-end.  
  *Unlike the Android test-bed, we **do not** inject JavaScript into the underlying `WKWebView` because `KetchUI.WebPresentationItem` (and its web view) is not part of the public API.  Validation is instead performed through `KetchEventListener` callbacks which update app-level status and `testResult` labels that the tests assert against.*

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

* macOS with **Xcode 15** or newer
* **iOS Simulator runtime ≥ iOS 15** installed  
  The helper script automatically picks the first available simulator (e.g. *iPhone 16, iOS 18*).
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
3. Choose any iOS 15+ simulator.
4. ⌘U to run all tests.

### 4  Run from command line (CI-friendly)

```bash
./run-integration-tests.sh
```

The script:
* generates the project (if missing)
* finds an available iOS simulator (preferring newest runtimes/devices)
* runs `xcodebuild test` on that destination and forwards output.

---

## Test Coverage

Current UI tests verify:

* **SDK boot-up** – app launches, `Ketch` is created, status shows *Ketch initialized*.
* **Configuration & Consent loading** – tapping **Load** triggers config & consent callbacks which update the on-screen labels.
* **Dialog presentation** – **Show Consent** / **Show Preferences** buttons present the expected experience; presence is confirmed via event-driven flags captured in `testResult` labels.
* **Dialog dismissal** – banner buttons are simulated (close action in ViewModel) and dismissal is confirmed via `onDismiss` → status label.
* **State display** – environment, consent, US Privacy, TCF & GPP values update as expected.
* **UI sanity** – all primary action buttons exist and are tappable.

---

## Sample App Features

Buttons (all have accessibility identifiers matching Android IDs):

* Load, Show Consent, Show Preferences  
* Set Language (EN), Set Jurisdiction (US), Set Region (California)

Labels:

* Status, Environment, Consent, US Privacy, TCF, GPP  
* Hidden **Test Actions** section exposes helper buttons & a `testResultText` label used by UI tests.

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
| **No suitable simulator found** | Install a recent iOS runtime in Xcode Settings → Platforms, or create a simulator via `xcrun simctl`. The script will auto-select once available. |
| **`xcodegen` command not found** | `brew install xcodegen` or install via Mint and ensure it’s in your `PATH`. |
| **Network / CDN errors or tests timing out** | The suite loads live configuration & experiences from Ketch servers. Make sure the machine has internet access (`cdn.ketchjs.com`, `global.ketchcdn.com`). Offline runs will fail or hang waiting for callbacks. |
| **`WKWebView` fails to load content in tests** | Reset simulator content & settings, then rerun. |

---

Happy testing!  
If you hit issues not covered here, open a GitHub issue or ping the SDK team.  
