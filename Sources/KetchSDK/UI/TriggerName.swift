//
//  TriggerName.swift
//  KetchSDK
//

/// The trigger name for `KetchUI.trigger(triggerName:functionName:options:)` — mirrors ketch-tag's
/// `ketch('trigger', 'custom', <functionName>, ...)` call shape. Other trigger names go through
/// `KetchUI.trigger(_:options:)`.
public enum TriggerName: String {
    case custom
}
