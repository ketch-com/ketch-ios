//
//  ManagedIdentity.swift
//  KetchSDK
//
//  Ketch-managed anonymous identifier, minted natively rather than by the web tag.
//

import Combine
import Foundation

extension KetchSDK {
    /// One entry of the configuration's `identities` map.
    ///
    /// `type` is a String rather than an enum: the tag defines eight identity types and can add
    /// more, and an enum would fail to decode a value this SDK has not been taught about.
    public struct IdentityDefinition: Codable, Equatable {
        public let type: String?
        public let variable: String?
        public let ttl: Double?
    }
}

/// Ketch-managed identifier: a UUID this SDK mints, persists and supplies to the tag as a query
/// parameter.
enum ManagedIdentity {
    static let storageKey = "ketch_managed_identity"
    static let mintedAtKey = "ketch_managed_identity_minted_at"

    /// Only identity spaces with this prefix are Ketch-managed.
    static let codePrefix = "swb_"

    /// Matches the web tag's cookie default.
    static let defaultTTLSeconds: TimeInterval = 400 * 86_400

    struct Descriptor: Equatable {
        let code: String
        let variable: String
        let ttlSeconds: TimeInterval
    }

    struct Resolved: Equatable {
        /// Query-parameter name. This is the config entry's `variable`, not its space code --
        /// the tag reads `queryStringFetcher(window, attribute.variable)`.
        let variable: String
        let value: String
    }

    static func mintValue() -> String {
        UUID().uuidString.lowercased()
    }

    static func key(organizationCode: String, propertyCode: String) -> String {
        "\(organizationCode)/\(propertyCode)"
    }

    /// The first Ketch-managed, query-string-sourced identity in `identities`.
    static func findManagedIdentity(
        in identities: [String: KetchSDK.IdentityDefinition]
    ) -> Descriptor? {
        // Sorted because Swift dictionaries have no stable order: an unsorted scan could pick a
        // different space code across launches when a property declares more than one candidate.
        for (code, entry) in identities.sorted(by: { $0.key < $1.key }) {
            guard code.hasPrefix(codePrefix), entry.type == "queryString" else { continue }

            let variable = entry.variable.flatMap { $0.isEmpty ? nil : $0 } ?? code
            let ttl = entry.ttl.flatMap { $0 > 0 ? TimeInterval($0) : nil } ?? defaultTTLSeconds
            return Descriptor(code: code, variable: variable, ttlSeconds: ttl)
        }
        return nil
    }

    /// The stored identifier, minting and persisting a new one when there is none or it has aged out.
    static func resolveValue(
        descriptor: Descriptor,
        storage: NativeStorage,
        now: () -> Date = Date.init
    ) -> String {
        let stored = storage.read(key: storageKey)
        if !stored.isEmpty {
            let mintedAt = TimeInterval(storage.read(key: mintedAtKey))
            // An unreadable timestamp is treated as expired: replacing the value is safer than
            // keeping one whose age cannot be established.
            let expired = mintedAt.map { now().timeIntervalSince1970 - $0 >= descriptor.ttlSeconds } ?? true
            if !expired { return stored }
        }

        let minted = mintValue()
        storage.write(key: storageKey, value: minted)
        storage.write(key: mintedAtKey, value: String(now().timeIntervalSince1970))
        return minted
    }

    /// Adds the managed identifier to an identity map. An app-supplied value under the same key wins.
    static func merged(_ identities: [String: String], with resolved: Resolved?) -> [String: String] {
        guard let resolved else { return identities }
        var result = [resolved.variable: resolved.value]
        result.merge(identities) { _, appSupplied in appSupplied }
        return result
    }

    /// Adds the managed identifier to an identity list.
    static func merged(_ identities: [Ketch.Identity], with resolved: Resolved?) -> [Ketch.Identity] {
        guard let resolved else { return identities }
        return [Ketch.Identity(key: resolved.variable, value: resolved.value)] + identities
    }
}

/// Loads the `identities` section of a property's configuration.
typealias IdentityConfigLoader = () -> AnyPublisher<[String: KetchSDK.IdentityDefinition]?, Error>

/// Resolves the Ketch-managed identifier, memoised per organization and property.
///
/// Resolution lives here rather than in `KetchUI` because headless calls run with no UI presented,
/// and anything resolving inside the UI would leave that path with no identifier. Memoising keeps
/// repeated calls to one config fetch per property; a single shared slot would instead be
/// overwritten by an app using more than one property.
final class ManagedIdentityResolver {
    static let shared = ManagedIdentityResolver()

    private let storage: NativeStorage
    private let lock = NSLock()
    private var memo = [String: ManagedIdentity.Resolved?]()
    private var waiting = [String: [(ManagedIdentity.Resolved?) -> Void]]()
    private var fetches = [String: AnyCancellable]()
    private var mostRecent: ManagedIdentity.Resolved?

    init(storage: NativeStorage = NativeStorage()) {
        self.storage = storage
    }

    /// The last identifier resolved by any property, or nil if none has been.
    ///
    /// Used where a request carries no property code and the identity space therefore cannot be
    /// looked up. Reusing the identifier already resolved is better than omitting it.
    func lastResolved() -> ManagedIdentity.Resolved? {
        lock.lock()
        defer { lock.unlock() }
        return mostRecent
    }

    func resolve(
        organizationCode: String,
        propertyCode: String,
        loadConfig: @escaping IdentityConfigLoader
    ) -> AnyPublisher<ManagedIdentity.Resolved?, Never> {
        let key = ManagedIdentity.key(organizationCode: organizationCode, propertyCode: propertyCode)

        // Deferred so a memoised answer is read at subscription time rather than when the enclosing
        // request is built, and so nothing is fetched for a publisher nobody subscribes to.
        return Deferred {
            Future { [weak self] promise in
                guard let self else { return promise(.success(nil)) }

                self.lock.lock()
                if let memoised = self.memo[key] {
                    self.lock.unlock()
                    return promise(.success(memoised))
                }
                if self.waiting[key] != nil {
                    self.waiting[key]?.append { promise(.success($0)) }
                    self.lock.unlock()
                    return
                }
                self.waiting[key] = [{ promise(.success($0)) }]
                self.lock.unlock()

                self.fetches[key] = loadConfig().sink(
                    receiveCompletion: { [weak self] completion in
                        // A property may legitimately declare no managed identity, and a failed
                        // config fetch must not stop consent from being requested. Failures are not
                        // memoised, so a later call retries rather than inheriting a network blip
                        // for the life of the process.
                        if case .failure(let error) = completion {
                            KetchLogger.log.warning(
                                "Managed identity resolution failed: \(error.localizedDescription)"
                            )
                            self?.finish(key: key, resolved: nil, memoise: false)
                        }
                    },
                    receiveValue: { [weak self] identities in
                        guard let self else { return }
                        var resolved: ManagedIdentity.Resolved?
                        if let identities,
                           let descriptor = ManagedIdentity.findManagedIdentity(in: identities) {
                            resolved = ManagedIdentity.Resolved(
                                variable: descriptor.variable,
                                value: ManagedIdentity.resolveValue(
                                    descriptor: descriptor, storage: self.storage
                                )
                            )
                        }
                        self.finish(key: key, resolved: resolved, memoise: true)
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }

    private func finish(key: String, resolved: ManagedIdentity.Resolved?, memoise: Bool) {
        lock.lock()
        if memoise {
            memo[key] = resolved
            if resolved != nil { mostRecent = resolved }
        }
        let callbacks = waiting.removeValue(forKey: key) ?? []
        fetches[key] = nil
        lock.unlock()

        callbacks.forEach { $0(resolved) }
    }

    /// Wipes the stored identifier. The next resolve mints a new one, which starts a new consent
    /// record. Identities supplied by the app are unaffected.
    ///
    /// Memoised resolutions hold the old value, so a clear that left them in place would hand the
    /// previous identifier back on the next call.
    func clear() {
        lock.lock()
        memo.removeAll()
        // Dropping fetches cancels any in-flight config request, and a cancelled request never
        // completes, so whoever is queued behind it has to be answered here instead.
        let abandoned = waiting.values.flatMap { $0 }
        waiting.removeAll()
        fetches.removeAll()
        mostRecent = nil
        lock.unlock()

        abandoned.forEach { $0(nil) }

        storage.removeObject(forKey: ManagedIdentity.storageKey)
        storage.removeObject(forKey: ManagedIdentity.mintedAtKey)
    }
}
