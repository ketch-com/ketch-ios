//
//  NativeResolveHandler.swift
//  KetchSDK
//

import Foundation
import UIKit
import WebKit

/// Extracts the `key` argument from the `ketchNativeResolve` message body (`{ key: string }`).
/// Pure and side-effect free. Returns `nil` for anything that isn't a well-formed, non-blank
/// string key — the handler replies `nil` in that case rather than throwing.
func parseNativeResolveKey(from body: Any) -> String? {
    guard let dict = body as? [String: Any],
          let key = dict["key"] as? String else { return nil }
    let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
}

private let idfvKey = "ketch_idfv"

/// Routes a `ketchNativeResolve` key to its value. `ketch_idfv` answers with the device's vendor
/// identifier, every other key reads from native storage.
func resolveNativeValue(
    key: String,
    nativeStorage: NativeStorage,
    identifierForVendor: () -> String? = { UIDevice.current.identifierForVendor?.uuidString }
) -> String? {
    key == idfvKey ? identifierForVendor() : nativeStorage.readIfPresent(key: key)
}

/// Bridges the tag's `ketchNativeResolve.postMessage({ key })` call to `NativeStorage`. Always
/// replies — with `nil` when nothing is stored — so the tag's own ~2s timeout is never hit.
/// Never writes: storage writes remain the existing `nativeStoragePut` handler's job.
///
/// `onResolve`, if set, is called with every key the tag asks about and whatever value (if any)
/// was found — this is how the SDK learns which storage keys are identities at all, since
/// `NativeStorage` also holds unrelated things (consent version, IAB privacy strings, ATT)
final class NativeResolveHandler: NSObject, WKScriptMessageHandlerWithReply {
    static let messageName = "ketchNativeResolve"

    private let nativeStorage: NativeStorage
    private let onResolve: ((String, String?) -> Void)?

    init(nativeStorage: NativeStorage, onResolve: ((String, String?) -> Void)? = nil) {
        self.nativeStorage = nativeStorage
        self.onResolve = onResolve
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage,
        replyHandler: @escaping (Any?, String?) -> Void
    ) {
        guard let key = parseNativeResolveKey(from: message.body) else {
            KetchLogger.log.error("ketchNativeResolve: malformed message body")
            replyHandler(nil, nil)
            return
        }
        let value = resolveNativeValue(key: key, nativeStorage: nativeStorage)
        if key != idfvKey {
            onResolve?(key, value)
        }
        replyHandler(value, nil)
    }
}
