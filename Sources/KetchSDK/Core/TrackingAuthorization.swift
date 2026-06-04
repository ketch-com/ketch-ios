//
//  TrackingAuthorization.swift
//  KetchSDK
//

import AppTrackingTransparency
import Foundation

extension KetchSDK {
    /// Current App Tracking Transparency authorization status (iOS 14+).
    /// Use before headless consent flows; pass to WebView via `ketch_att` when showing the experience.
    @available(iOS 14, *)
    public static func trackingAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    /// String form of ATT status for WebView query params (matches `PresentationItem` / `ketch_att`).
    @available(iOS 14, *)
    public static func trackingAuthorizationStatusString() -> String {
        ATTrackingManager.trackingAuthorizationStatus.asString
    }
}
