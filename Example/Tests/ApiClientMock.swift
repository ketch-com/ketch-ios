//
//  ApiClientMock.swift
//  KetchSDK_Tests
//

import Foundation
import Combine
@testable import KetchSDK

class ApiClientMock: ApiClient {
    let publisher: PassthroughSubject<[String: Any], ApiClientError>

    init(publisher: PassthroughSubject<[String: Any], ApiClientError>) {
        self.publisher = publisher
    }

    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError> {
        publisher
            .map { try! JSONSerialization.data(withJSONObject: $0, options: []) }
            .eraseToAnyPublisher()
    }
}
