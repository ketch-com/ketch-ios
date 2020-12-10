//
//  NetworkEngineGRPC.swift
//  Ketch
//
//  Created by Andrii Andreiev on 04.12.2020.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import GRPC
import NIO

protocol NetworkEngineGRPC {
    
    /// Creates tasks for retrieveing Configuration for specific environment and region
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter regionCode: The code of USA region needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code
    /// - Returns: Network task that provides `Configuration` object or network error as a result
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, languageCode: String, completion:@escaping (NetworkTaskResult<Configuration>)->())
    
}

class NetworkEngineGRPCImpl: NetworkEngineGRPC {
    
    // MARK: Initializer

    /// Initializer
    /// - Parameter settings: Settings for API which contains `organizationId` and `applicationId`
    /// - Parameter session: URLSession used to send network requests
    /// - Parameter cachingEngine: Engine for caching network responses
    init(settings: Settings, cachingEngine: CacheEngine, printDebugInfo: Bool = false) {
        self.settings = settings
        self.cacheStore = CacheStore(settings: settings, engine: cachingEngine)
        self.printDebugInfo = printDebugInfo
        self.channel = ClientConnection.secure(group: MultiThreadedEventLoopGroup(numberOfThreads: 1)).connect(host: "mobile.dev.b10s.io", port: 443)
        self.client = Mobile_MobileClient(channel: channel)
    }
        
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, languageCode: String, completion:@escaping (NetworkTaskResult<Configuration>)->()) {
        
        let options: Mobile_GetConfigurationRequest = .with {
            $0.organizationCode = self.settings.organizationCode
            $0.applicationCode = self.settings.applicationCode
            $0.applicationEnvironmentCode = environmentCode
            $0.countryCode = countryCode
            $0.regionCode = regionCode ?? ""
            $0.languageCode = languageCode
        }
        
        let call = client.getConfiguration(options)
        
        call.response.whenSuccess { configuratoionResponse in
            let configuration = Configuration(response: configuratoionResponse)
            // TODO: cache save
            completion(.success(configuration))
        }
        
        call.response.whenFailure { error in
            // TODO: try cache retrive
            completion(.failure(.serverNotReachable)) // TODO: proper error
        }
    }
    
    // MARK: Private

    /// GRPCChannel used to sync network requests
    private let channel: GRPCChannel
    
    /// Client object generated for sending gRPC requests
    private let client: Mobile_MobileClient!

    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings

    /// Store that is responsible to save and retrieve cache of network responses
    private let cacheStore: CacheStore

    /// Dedicated Queue to add and remove tasks thread-safety
    private let tasksUpdateQueue = DispatchQueue(label: "NetworkEngine")

    /// Map of active tasks
    private var tasks = [String: Any]()

    /// Property to print debug info.
    private let printDebugInfo: Bool
    
}
