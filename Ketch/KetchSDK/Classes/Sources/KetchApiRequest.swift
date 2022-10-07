//
//  KetchApiRequest.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.10.2022.
//

import Foundation
import Combine

enum KetchApiRequest {
    static func fetchConfig() -> AnyPublisher<Configuration, Error> {
        ApiRequest.execute(
            with: URL(
                string: "https://global.ketchcdn.com/web/v2/config/transcenda/website_smart_tag/production/13171895563553497268/default/en/config.json"
            )!
        )
        .eraseToAnyPublisher()
    }
}

