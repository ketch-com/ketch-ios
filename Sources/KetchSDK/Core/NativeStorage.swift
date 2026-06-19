//
//  NativeStorage.swift
//  KetchSDK
//

import Foundation

/// String key/value persistence backed by UserDefaults, written via the `nativeStoragePut` bridge event.
struct NativeStorage {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func read(key: String, defaultValue: String = "") -> String {
        userDefaults.string(forKey: key) ?? defaultValue
    }

    func write(key: String, value: String) {
        userDefaults.set(value, forKey: key)
    }

    // MARK: - Generic value access (mirrors UserDefaults set/value)

    func set(_ value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func value(forKey key: String) -> Any? {
        userDefaults.value(forKey: key)
    }

    // MARK: - Removal

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    /// Removes every stored key whose name begins with one of `prefixes`. Returns the count removed.
    @discardableResult
    func removeValues(withPrefixes prefixes: [String]) -> Int {
        let keys = userDefaults.dictionaryRepresentation().keys.filter { key in
            prefixes.contains { key.hasPrefix($0) }
        }
        keys.forEach { userDefaults.removeObject(forKey: $0) }
        return keys.count
    }
}
