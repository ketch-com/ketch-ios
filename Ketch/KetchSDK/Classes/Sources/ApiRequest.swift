//
//  ApiService.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.10.2022.
//

import Foundation
import Combine

enum ApiRequest {
    static func execute<T: Codable>(with url: URL) -> AnyPublisher<T, Error> {
        let request = URLRequest(url: url)

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                guard httpResponse.statusCode == 200 else {
                    throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
                }

                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
