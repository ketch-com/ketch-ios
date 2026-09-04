//
//  NativeResolveHandler.swift
//  KetchSDK
//

import Foundation
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

/// Bridges the tag's `ketchNativeResolve.postMessage({ key })` call to `NativeStorage`. Always
/// replies — with `nil` when nothing is stored — so the tag's own ~2s timeout is never hit.
/// Never writes: storage writes remain the existing `nativeStoragePut` handler's job.
final class NativeResolveHandler: NSObject, WKScriptMessageHandlerWithReply {
    static let messageName = "ketchNativeResolve"

    private let nativeStorage: NativeStorage

    init(nativeStorage: NativeStorage) {
        self.nativeStorage = nativeStorage
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
        replyHandler(nativeStorage.readIfPresent(key: key), nil)
    }
}
