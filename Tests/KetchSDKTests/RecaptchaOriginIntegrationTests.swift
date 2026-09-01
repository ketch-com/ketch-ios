import WebKit
import XCTest
@testable import KetchSDK

/// Live reCAPTCHA handshake under the SDK's document origin (Google endpoints, sandbox site key).
///
/// reCAPTCHA exchanges messages with a hidden Google iframe over `postMessage`, which cannot
/// address the `null` origin a `file:` document serializes to. When that handshake fails,
/// `grecaptcha.execute()` still resolves — with a short placeholder beginning `HF`, which the
/// server then rejects. A real origin yields a genuine token instead.
///
/// Run with network enabled:
/// `TEST_RUNNER_KETCH_INTEGRATION_TESTS=1 xcodebuild -scheme KetchSDK -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:KetchSDKTests/RecaptchaOriginIntegrationTests`
final class RecaptchaOriginIntegrationTests: XCTestCase {
    /// Site key from the live ketch_samples/ios production configuration.
    private static let siteKey = "6Lc76pAjAAAAAEJst8tq0k8QiuEptxY3m4CbekVB"

    private final class Waiter: NSObject, WKNavigationDelegate {
        private let expectation: XCTestExpectation
        init(_ expectation: XCTestExpectation) { self.expectation = expectation }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { expectation.fulfill() }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            expectation.fulfill()
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            expectation.fulfill()
        }
    }
    private var waiter: Waiter?

    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["KETCH_INTEGRATION_TESTS"] == "1",
            "Set KETCH_INTEGRATION_TESTS=1 to run live reCAPTCHA tests"
        )
    }

    private var html: String {
        """
        <html><head>
        <script>window.__token = null; window.__state = 'init';</script>
        <script src="https://www.google.com/recaptcha/api.js?render=\(Self.siteKey)"></script>
        </head><body><script>
          setTimeout(function () {
            if (!window.grecaptcha) { window.__state = 'no-grecaptcha'; return; }
            grecaptcha.ready(function () {
              window.__state = 'executing';
              grecaptcha.execute('\(Self.siteKey)', { action: 'submit' })
                .then(function (t) { window.__token = t; window.__state = 'done'; })
                .catch(function (e) { window.__state = 'error:' + e; });
            });
          }, 500);
        </script></body></html>
        """
    }

    private func evaluate(_ js: String, in webView: WKWebView) -> String {
        let done = expectation(description: js)
        var out = "<none>"
        webView.evaluateJavaScript(js) { value, error in
            if let error { out = "<error: \(error.localizedDescription)>" } else if let value { out = String(describing: value) }
            done.fulfill()
        }
        wait(for: [done], timeout: 20)
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func settle(_ seconds: Double) {
        let done = expectation(description: "settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { done.fulfill() }
        wait(for: [done], timeout: seconds + 10)
    }

    func testCaptchaTokenIsRealUnderDocumentOrigin() throws {
        let config = WebConfig(
            orgCode: "ketch_samples",
            propertyName: "ios",
            environmentCode: "production",
            advertisingIdentifiers: []
        )
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 390, height: 800))
        let loaded = expectation(description: "loaded")
        waiter = Waiter(loaded)
        webView.navigationDelegate = waiter
        webView.loadHTMLString(html, baseURL: try XCTUnwrap(config.documentURL))
        wait(for: [loaded], timeout: 30)

        var state = ""
        for _ in 0..<12 {
            settle(2)
            state = evaluate("window.__state", in: webView)
            if state == "done" || state.hasPrefix("error") { break }
        }

        XCTAssertEqual(evaluate("origin", in: webView), WebConfig.documentOrigin)
        XCTAssertEqual(state, "done", "grecaptcha.execute did not resolve")

        let token = evaluate("window.__token || ''", in: webView)
        XCTAssertFalse(token.hasPrefix("HF"), "Got the broken-handshake placeholder, not a token")
        XCTAssertGreaterThan(token.count, 1000, "Token is too short to be a real one")
    }
}
