---
name: ketch-ios-run-sample
description: Configures the in-repo iOS sample app for either the released KetchSDK Swift package from GitHub (latest semver tag by default) or the local checkout, boots a simulator when needed, builds, installs, and streams console plus filtered unified logs. Use when the user runs /ketch-ios-run-sample, wants the sample against the latest remote SPM tag, or says local to test against the workspace package.
---

# ketch-ios-run-sample

## Instructions

When the user invokes **`/ketch-ios-run-sample`** (or asks to run the sample with production / local SDK):

1. `cd` to the `ketch-ios` repository root (`/Users/justin/Source/ketch-com/ketch-ios` or the workspace root that contains `Package.swift` and `Examples/KetchSDKSample`).

2. Run the helper script:

**Released package (default)** — rewrites the sample Xcode project to use GitHub SPM. There is **no `latest` token in the repository URL**; SwiftPM resolves versions from the `requirement` block. By default the configure step runs **`git ls-remote --tags`** on the GitHub URL, picks the **highest `X.Y.Z` tag**, and sets **`exactVersion`** to that tag (not derived from CocoaPods).

```bash
bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh
```

**Local package** — rewrites the sample Xcode project to use the repo checkout (`../..`):

```bash
bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh local
```

The script boots a simulator when none is running, builds `KetchSDK-Example`, installs, streams unified logs for subsystem `com.ketch.sdk` (when the linked SDK supports it), and launches with `--console-pty`. Stop with `Ctrl-C`.

## Remote overrides

```bash
# Pin an exact release (no tag discovery)
KETCH_IOS_SPM_VERSION=4.6.0 bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh

# Track a branch instead of latest tag (moving HEAD)
KETCH_IOS_SPM_BRANCH=main bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh

# Fork or mirror
KETCH_IOS_SPM_REPO_URL="https://github.com/org/ketch-ios.git" bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh
```

## Other options

```bash
SIMULATOR_NAME="iPhone 15 Pro" bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh
DEVICE_ID="<uuid>" bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh local
bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh --build-only
bash .cursor/skills/ketch-ios-run-sample/scripts/run-sample-app.sh --full-system-logs
```

## Notes

- Default remote mode needs **`git`** and network access for `git ls-remote` when not pinning with `KETCH_IOS_SPM_VERSION`.
- The unified-log filter depends on `Logger(subsystem: "com.ketch.sdk", ...)` in the linked SDK; older released tags may log under a different subsystem until upgraded.
