//
//  TrackingAuthorization.swift
//  KetchSDK
//

import AppTrackingTransparency
import Foundation

extension KetchSDK {
    /// Current App Tracking Transparency authorization status (iOS 14+).
    /// Pass to WebView via `ketch_att` on load/reload (not sent on headless HTTP).
    @available(iOS 14, *)
    public static func trackingAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    /// String form of ATT status for WebView query params (matches `PresentationItem` / `ketch_att`).
    @available(iOS 14, *)
    public static func trackingAuthorizationStatusString() -> String {
        ATTrackingManager.trackingAuthorizationStatus.asString
    }

    /// UserDefaults key for the last ATT status persisted via `nativeStoragePut` from ketch-tag.
    static let attLastStorageKey = "ketch_att_last"
}
