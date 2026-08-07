//
//  TriggerName.swift
//  KetchSDK
//

/// The trigger name for `KetchUI.trigger` — mirrors ketch-tag's `ketch('trigger', <triggerName>, ...)`
/// call shape. `.custom` is the only supported value today.
public enum TriggerName: String {
    case custom
}
