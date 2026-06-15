//
//  NativeStorage.swift
//  KetchSDK
//

import Foundation

/// String key/value persistence backed by UserDefaults, written via the `nativeStoragePut` bridge event.
struct NativeStorage {
    static let ketchAttLastKey = "ketch_att_last"

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
}
