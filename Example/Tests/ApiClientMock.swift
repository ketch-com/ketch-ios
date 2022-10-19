//
//  ApiClientMock.swift
//  KetchSDK_Tests
//
//  Created by Anton Lyfar on 12.10.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
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
