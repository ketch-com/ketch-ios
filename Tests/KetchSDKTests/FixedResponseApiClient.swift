import Combine
import Foundation
@testable import KetchSDK

/// Answers every request synchronously from an in-memory body.
///
/// `KetchUI` waits on a config fetch before it builds its WebView, so a test that leaves the real
/// network in place gets no presentation item at all.
final class FixedResponseApiClient: ApiClient {
    private let body: Data

    /// Defaults to a property that declares no identities, which resolves to no managed identifier.
    init(json: String = #"{"identities":{}}"#) {
        body = Data(json.utf8)
    }

    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError> {
        Just(body).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
    }
}
