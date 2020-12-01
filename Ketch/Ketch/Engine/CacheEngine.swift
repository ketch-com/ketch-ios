//
//  CacheEngine.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/31/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// Engine for caching network responses
protocol CacheEngine {

    /// Saves the codable object in the cache with associated key
    /// - Parameter key: The associated key
    /// - Parameter object: The object to cache
    func save<T>(key: String, object: T) where T: Codable

    /// Retrieves the codable object from the cache by associated key
    /// - Parameter key: The associated key
    /// - Returns: The cached object or nil if the cache is missed
    func retrieve<T: Codable>(key: String) -> T?
}

// MARK: -

/// Engine for caching network responses in files
class FileCacheEngine {

    // MARK: Initializer

    /// Initializer.
    /// Can persist cache only for one combination of `organizationId` and `applicationId`
    /// If there are caches for other combination of `organizationId` and `applicationId`, the old cache will be deleted because of security reason
    /// - Parameter settings: Settings for API which contains `organizationId` and `applicationId`
    init(settings: Settings, printDebugInfo: Bool = false) {
        self.settings = settings
        self.printDebugInfo = printDebugInfo
    }

    // MARK: Private Properties

    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings

    /// Property to print debug info.
    private let printDebugInfo: Bool

    /// URL of folder to persist caches. The folder path is associated with provided `settings` and persists in hidden folder
    private lazy var cacheStoreFolder: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let folderName = (settings.organizationCode + "_" + settings.applicationCode).sha256
        let rootURL = paths[0].appendingPathComponent(".file_cache_engine")
        var folders = (try? FileManager.default.contentsOfDirectory(atPath: rootURL.path)) ?? []
        folders = folders.filter { $0 != folderName }

        folders.forEach { (folder) in
            try? FileManager.default.removeItem(at: rootURL.appendingPathComponent(folder))
        }
        let url = rootURL.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                if printDebugInfo {
                    print("🛑 Error creating cache folder at url: \(url): \(error)")
                }
            }
        }
        return url
    }()
}

// MARK: -
// MARK: FileCacheEngine: CacheEngine

extension FileCacheEngine: CacheEngine {

    /// Saves the codable object in the cache with associated key
    /// Prints errors if cannot encode cache object in JSON or save cache file
    /// - Parameter key: The associated key
    /// - Parameter object: The object to cache
    func save<T>(key: String, object: T) where T: Codable {
        let url = cacheStoreFolder.appendingPathComponent(key)
        let data: Data
        do {
            data = try JSONEncoder().encode(object)
        } catch let error {
            if printDebugInfo {
                print("🛑 Error creating cache data from object: \(object): \(error)")
            }
            return
        }
        do {
            try data.write(to: url)
        } catch let error {
            if printDebugInfo {
                print("🛑 Error writting cache data to url: \(url): \(error)")
            }
        }
        if printDebugInfo {
            print("♒️ success saved cache to url \(url)")
        }
    }

    /// Retrieves the codable object from the cache by associated key.
    /// Prints errors if cannot read cache file or decode cache object from JSON
    /// - Parameter key: The associated key
    /// - Returns: The cached object or nil if the cache is missed
    func retrieve<T: Codable>(key: String) -> T? {
        let url = cacheStoreFolder.appendingPathComponent(key)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch let error {
            if printDebugInfo {
                print("🛑 Error getting cache data from url: \(url): \(error)")
            }
            return nil
        }
        let object: T
        do {
            object = try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            if printDebugInfo {
                print("🛑 Error getting object from data retrieved from url: \(url): \(error)")
            }
            return nil
        }
        if printDebugInfo {
            print("♒️ success retrieve cache from url \(url)")
        }
        return object
    }
}
