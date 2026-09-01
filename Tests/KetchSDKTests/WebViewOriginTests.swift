import XCTest
import WebKit
@testable import KetchSDK

/// Locks in the security origin WebKit grants the document. A `file:` base URL yields an opaque
/// origin that serializes as `null`, which reCAPTCHA's postMessage handshake cannot address, so
/// `grecaptcha.execute()` returns a placeholder instead of a token.
final class WebViewOriginTests: XCTestCase {
    private final class LoadWaiter: NSObject, WKNavigationDelegate {
        private let expectation: XCTestExpectation
        init(_ expectation: XCTestExpectation) { self.expectation = expectation }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { expectation.fulfill() }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            expectation.fulfill()
        }
    }

    private var waiter: LoadWaiter?

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

    private func loadedWebView(baseURL: URL) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        let done = expectation(description: "loaded \(baseURL)")
        waiter = LoadWaiter(done)
        webView.navigationDelegate = waiter
        webView.loadHTMLString("<html><head></head><body>probe</body></html>", baseURL: baseURL)
        wait(for: [done], timeout: 20)
        return webView
    }

    func testDocumentURL_grantsRealSecurityOrigin() throws {
        let config = WebConfig(
            orgCode: "testorg",
            propertyName: "testproperty",
            environmentCode: "production",
            advertisingIdentifiers: []
        )
        let webView = loadedWebView(baseURL: try XCTUnwrap(config.documentURL))

        XCTAssertEqual(evaluate("origin", in: webView), WebConfig.documentOrigin)
        XCTAssertNotEqual(evaluate("origin", in: webView), "null")
    }

    /// index.html boots the tag from `new URL(document.location).searchParams`, so the query has to
    /// survive onto the loaded document.
    func testDocumentURL_queryParamsReachTheDocument() throws {
        let config = WebConfig(
            orgCode: "testorg",
            propertyName: "testproperty",
            environmentCode: "production",
            advertisingIdentifiers: []
        )
        let webView = loadedWebView(baseURL: try XCTUnwrap(config.documentURL))

        XCTAssertEqual(evaluate("new URL(document.location).searchParams.get('orgCode')", in: webView), "testorg")
        XCTAssertEqual(evaluate("new URL(document.location).searchParams.get('isMobileSdk')", in: webView), "true")
    }
}
