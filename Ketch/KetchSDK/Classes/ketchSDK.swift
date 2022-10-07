//
//  ketchSDK.swift
//  ketchSDK
//
//  Created by Anton Lyfar on 05.10.2022.
//

import Combine

public protocol KetchSDK_Protocol {
    func config()
}

public class KetchSDK: KetchSDK_Protocol {
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        
    }

    public func config() {
        KetchApiRequest
            .fetchConfig()
            .sink { error in
                print(error)
            } receiveValue: { config in
                print(config)
            }
            .store(in: &subscriptions)
    }
}
