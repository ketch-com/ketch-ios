//
//  ketchSDK.swift
//  ketchSDK
//
//  Created by Anton Lyfar on 05.10.2022.
//

public protocol KetchSDK_Protocol {
    func config()
}

public class KetchSDK: KetchSDK_Protocol {
    public init() {
        
    }

    public func config() {
        print("RunConfig")
    }
}
