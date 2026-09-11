import XCTest
import WebKit
@testable import KetchSDK

/// Exercises the real `WKScriptMessageHandlerWithReply` registration and the JS promise round
/// trip — the one thing `ResolveNativeValueTests` can't cover, since `WKScriptMessage` has no
/// usable initializer for constructing one directly.
final class NativeResolveHandlerBridgeTests: XCTestCase {
    private final class LoadWaiter: NSObject, WKNavigationDelegate {
        private let expectation: XCTestExpectation
        init(_ expectation: XCTestExpectation) { self.expectation = expectation }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { expectation.fulfill() }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            expectation.fulfill()
        }
    }

    private var waiter: LoadWaiter?
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "NativeResolveHandlerBridgeTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        if let suiteName {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    private func evaluate(_ js: String, in webView: WKWebView) -> String {
        let done = expectation(description: "eval \(js)")
        var result = "<none>"
        webView.evaluateJavaScript(js) { value, error in
            if let error {
                result = "<error: \(error.localizedDescription)>"
            } else if let value {
                result = String(describing: value)
            }
            done.fulfill()
        }
        wait(for: [done], timeout: 10)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Fires the reply-based `postMessage` and polls a plain global for its resolution, rather
    /// than relying on `evaluateJavaScript` to auto-await the returned promise (unreliable for a
    /// reply-handler promise in this WebKit version — the direct approach surfaced
    /// "unsupported type" errors instead of the resolved value).
    private func postMessageAndAwaitReply(key: String, in webView: WKWebView) -> String {
        _ = evaluate(
            """
            window.__nativeResolveResult = undefined;
            window.webkit.messageHandlers.ketchNativeResolve.postMessage({ key: '\(key)' })
                .then(v => { window.__nativeResolveResult = (v === null || v === undefined) ? '<null>' : v; })
                .catch(e => { window.__nativeResolveResult = '<rejected: ' + e + '>'; });
            'posted'
            """,
            in: webView
        )

        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            let value = evaluate("typeof window.__nativeResolveResult === 'undefined' ? '<pending>' : window.__nativeResolveResult", in: webView)
            if value != "<pending>" {
                return value
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return "<timed out>"
    }

    private func loadedWebView(registering handler: NativeResolveHandler) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addScriptMessageHandler(
            handler,
            contentWorld: .page,
            name: NativeResolveHandler.messageName
        )

        let webView = WKWebView(frame: .zero, configuration: configuration)
        let done = expectation(description: "loaded")
        waiter = LoadWaiter(done)
        webView.navigationDelegate = waiter
        webView.loadHTMLString("<html><head></head><body>probe</body></html>", baseURL: nil)
        wait(for: [done], timeout: 20)
        return webView
    }

    /// Mirrors what the tag actually does: `window.webkit.messageHandlers.ketchNativeResolve
    /// .postMessage({ key })`, awaiting the reply.
    func testIDFVKeyRepliesWithVendorIdentifierOverRealBridge() {
        let storage = NativeStorage(userDefaults: userDefaults)
        let handler = NativeResolveHandler(nativeStorage: storage)
        let webView = loadedWebView(registering: handler)

        let result = postMessageAndAwaitReply(key: "ketch_idfv", in: webView)

        // The simulator is unlocked, so IDFV resolves to a real UUID string here.
        XCTAssertEqual(UUID(uuidString: result)?.uuidString.lowercased(), result.lowercased())
    }

    func testOrdinaryKeyStillRepliesWithStoredValueOverRealBridge() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.write(key: "swb_x", value: "stored-value")
        let handler = NativeResolveHandler(nativeStorage: storage)
        let webView = loadedWebView(registering: handler)

        let result = postMessageAndAwaitReply(key: "swb_x", in: webView)

        XCTAssertEqual(result, "stored-value")
    }
}
