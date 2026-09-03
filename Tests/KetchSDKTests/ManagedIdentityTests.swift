import Combine
import XCTest
@testable import KetchSDK

final class ManagedIdentityTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var storage: NativeStorage!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        suiteName = UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)
        storage = NativeStorage(userDefaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        cancellables.removeAll()
        super.tearDown()
    }

    private func definition(type: String?, variable: String? = nil, ttl: Double? = nil)
    -> KetchSDK.IdentityDefinition {
        KetchSDK.IdentityDefinition(type: type, variable: variable, ttl: ttl)
    }

    // MARK: - Minting

    func testMintValue_isLowercaseUUID() {
        let value = ManagedIdentity.mintValue()
        XCTAssertEqual(value, value.lowercased(), "web mints lowercase; a mismatch keys a different person")
        XCTAssertNotNil(UUID(uuidString: value))
        XCTAssertEqual(value.count, 36)
    }

    func testMintValue_isUnique() {
        let values = Set((0..<1_000).map { _ in ManagedIdentity.mintValue() })
        XCTAssertEqual(values.count, 1_000)
    }

    // MARK: - Descriptor selection

    func testFindManagedIdentity_queryStringWithSwbPrefix() {
        let found = ManagedIdentity.findManagedIdentity(in: [
            "swb_android": definition(type: "queryString", variable: "swb_android", ttl: 34_560_000)
        ])
        XCTAssertEqual(found, ManagedIdentity.Descriptor(
            code: "swb_android", variable: "swb_android", ttlSeconds: 34_560_000
        ))
    }

    func testFindManagedIdentity_ignoresManagedCookie() {
        let found = ManagedIdentity.findManagedIdentity(in: [
            "swb_android": definition(type: "managedCookie", variable: "_swb")
        ])
        XCTAssertNil(found, "the tag mints its own value for managedCookie and ignores anything supplied")
    }

    func testFindManagedIdentity_ignoresNonSwbQueryString() {
        let found = ManagedIdentity.findManagedIdentity(in: [
            "crm_id": definition(type: "queryString", variable: "crm_id")
        ])
        XCTAssertNil(found, "a non-swb query-string identity is the host app's to supply")
    }

    func testFindManagedIdentity_picksDeterministicallyAmongCandidates() {
        let identities = [
            "swb_zulu": definition(type: "queryString"),
            "swb_alpha": definition(type: "queryString"),
            "swb_mike": definition(type: "queryString")
        ]
        // Swift dictionaries have no stable order; the same input must not pick differently.
        let picks = Set((0..<50).map { _ in
            ManagedIdentity.findManagedIdentity(in: identities)?.code
        })
        XCTAssertEqual(picks, ["swb_alpha"])
    }

    func testFindManagedIdentity_fallsBackToCodeWhenVariableEmpty() {
        XCTAssertEqual(
            ManagedIdentity.findManagedIdentity(in: ["swb_x": definition(type: "queryString", variable: "")])?.variable,
            "swb_x"
        )
        XCTAssertEqual(
            ManagedIdentity.findManagedIdentity(in: ["swb_x": definition(type: "queryString")])?.variable,
            "swb_x"
        )
    }

    func testFindManagedIdentity_ttlFallback() {
        for ttl in [nil, Double(0), Double(-1)] {
            XCTAssertEqual(
                ManagedIdentity.findManagedIdentity(in: ["swb_x": definition(type: "queryString", ttl: ttl)])?.ttlSeconds,
                ManagedIdentity.defaultTTLSeconds
            )
        }
    }

    func testFindManagedIdentity_emptyAndUnknownTypes() {
        XCTAssertNil(ManagedIdentity.findManagedIdentity(in: [:]))
        XCTAssertNil(ManagedIdentity.findManagedIdentity(in: ["swb_x": definition(type: nil)]))
        XCTAssertNil(ManagedIdentity.findManagedIdentity(in: ["swb_x": definition(type: "localStorage")]))
    }

    // MARK: - Value persistence and TTL

    private func descriptor(ttl: TimeInterval = 100) -> ManagedIdentity.Descriptor {
        .init(code: "swb_android", variable: "swb_android", ttlSeconds: ttl)
    }

    func testResolveValue_mintsAndPersists() {
        let now = Date(timeIntervalSince1970: 1_000)
        let value = ManagedIdentity.resolveValue(descriptor: descriptor(), storage: storage, now: { now })

        XCTAssertEqual(storage.read(key: ManagedIdentity.storageKey), value)
        XCTAssertEqual(TimeInterval(storage.read(key: ManagedIdentity.mintedAtKey)), 1_000)
    }

    func testResolveValue_reusesWithinTTL() {
        let first = ManagedIdentity.resolveValue(
            descriptor: descriptor(), storage: storage, now: { Date(timeIntervalSince1970: 1_000) }
        )
        let second = ManagedIdentity.resolveValue(
            descriptor: descriptor(), storage: storage, now: { Date(timeIntervalSince1970: 1_099) }
        )
        XCTAssertEqual(first, second)
    }

    func testResolveValue_remintsExactlyAtTTLBoundary() {
        let first = ManagedIdentity.resolveValue(
            descriptor: descriptor(ttl: 100), storage: storage, now: { Date(timeIntervalSince1970: 1_000) }
        )
        let second = ManagedIdentity.resolveValue(
            descriptor: descriptor(ttl: 100), storage: storage, now: { Date(timeIntervalSince1970: 1_100) }
        )
        XCTAssertNotEqual(first, second, "the boundary counts as expired")
    }

    func testResolveValue_lifetimeIsFixedFromMintNotSliding() {
        let first = ManagedIdentity.resolveValue(
            descriptor: descriptor(ttl: 100), storage: storage, now: { Date(timeIntervalSince1970: 1_000) }
        )
        // A read partway through must not push the expiry out.
        _ = ManagedIdentity.resolveValue(
            descriptor: descriptor(ttl: 100), storage: storage, now: { Date(timeIntervalSince1970: 1_050) }
        )
        let third = ManagedIdentity.resolveValue(
            descriptor: descriptor(ttl: 100), storage: storage, now: { Date(timeIntervalSince1970: 1_101) }
        )
        XCTAssertNotEqual(first, third)
    }

    func testResolveValue_remintsWhenTimestampUnreadable() {
        storage.write(key: ManagedIdentity.storageKey, value: "stored-value")
        storage.write(key: ManagedIdentity.mintedAtKey, value: "not-a-number")

        let value = ManagedIdentity.resolveValue(descriptor: descriptor(), storage: storage)
        XCTAssertNotEqual(value, "stored-value")
    }

    // MARK: - Merging

    func testMerged_appSuppliedWinsOnCollision() {
        let resolved = ManagedIdentity.Resolved(variable: "swb_android", value: "managed")
        let merged = ManagedIdentity.merged(["swb_android": "app", "email": "a@b.c"], with: resolved)

        XCTAssertEqual(merged["swb_android"], "app")
        XCTAssertEqual(merged["email"], "a@b.c")
    }

    func testMerged_addsManagedWhenAbsent() {
        let resolved = ManagedIdentity.Resolved(variable: "swb_android", value: "managed")
        XCTAssertEqual(ManagedIdentity.merged([:], with: resolved), ["swb_android": "managed"])
    }

    func testMerged_nilResolvedPassesThrough() {
        XCTAssertEqual(ManagedIdentity.merged(["email": "a@b.c"], with: nil), ["email": "a@b.c"])
    }

    func testMergedIdentityList_putsManagedFirstSoAppSuppliedWinsInQueryItems() {
        let resolved = ManagedIdentity.Resolved(variable: "swb_android", value: "managed")
        let merged = ManagedIdentity.merged([Ketch.Identity(key: "swb_android", value: "app")], with: resolved)

        // WebConfig.queryItems folds the list into a dictionary, so the later entry wins.
        XCTAssertEqual(merged.map(\.value), ["managed", "app"])
        var folded = [String: String]()
        merged.forEach { folded[$0.key] = $0.value }
        XCTAssertEqual(folded["swb_android"], "app")
    }

    // MARK: - Resolver

    private func loader(
        _ identities: [String: KetchSDK.IdentityDefinition]?,
        calls: (() -> Void)? = nil
    ) -> IdentityConfigLoader {
        {
            calls?()
            return Just(identities).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }

    private var queryStringConfig: [String: KetchSDK.IdentityDefinition] {
        ["swb_android": definition(type: "queryString", variable: "swb_android", ttl: 34_560_000)]
    }

    private func resolve(
        _ resolver: ManagedIdentityResolver,
        organization: String = "acme",
        property: String = "ios",
        loadConfig: @escaping IdentityConfigLoader
    ) -> ManagedIdentity.Resolved? {
        var result: ManagedIdentity.Resolved?
        let done = expectation(description: "resolve")
        resolver.resolve(
            organizationCode: organization, propertyCode: property, loadConfig: loadConfig
        )
        .sink { result = $0; done.fulfill() }
        .store(in: &cancellables)
        wait(for: [done], timeout: 2)
        return result
    }

    func testResolver_resolvesAndMints() {
        let resolver = ManagedIdentityResolver(storage: storage)
        let resolved = resolve(resolver, loadConfig: loader(queryStringConfig))

        XCTAssertEqual(resolved?.variable, "swb_android")
        XCTAssertEqual(resolved?.value, storage.read(key: ManagedIdentity.storageKey))
    }

    func testResolver_memoisesOneConfigFetchPerProperty() {
        let resolver = ManagedIdentityResolver(storage: storage)
        var fetches = 0
        let load = loader(queryStringConfig) { fetches += 1 }

        let first = resolve(resolver, loadConfig: load)
        let second = resolve(resolver, loadConfig: load)

        XCTAssertEqual(fetches, 1)
        XCTAssertEqual(first, second)
    }

    func testResolver_memoisesPerPropertyNotGlobally() {
        let resolver = ManagedIdentityResolver(storage: storage)
        var fetches = 0
        let load = loader(queryStringConfig) { fetches += 1 }

        _ = resolve(resolver, property: "ios", loadConfig: load)
        _ = resolve(resolver, property: "tvos", loadConfig: load)

        XCTAssertEqual(fetches, 2, "a second property must not read the first property's slot")
    }

    func testResolver_coalescesConcurrentResolves() {
        let resolver = ManagedIdentityResolver(storage: storage)
        var fetches = 0
        let gate = PassthroughSubject<[String: KetchSDK.IdentityDefinition]?, Error>()
        let load: IdentityConfigLoader = {
            fetches += 1
            return gate.eraseToAnyPublisher()
        }

        var results = [ManagedIdentity.Resolved?]()
        for _ in 0..<3 {
            resolver.resolve(
                organizationCode: "acme", propertyCode: "ios", loadConfig: load
            )
            .sink { results.append($0) }
            .store(in: &cancellables)
        }
        gate.send(queryStringConfig)

        XCTAssertEqual(fetches, 1, "callers arriving during a fetch must share it")
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(Set(results.map { $0?.value }).count, 1)
    }

    func testResolver_managedCookieResolvesToNothing() {
        let resolver = ManagedIdentityResolver(storage: storage)
        let resolved = resolve(resolver, loadConfig: loader([
            "swb_android": definition(type: "managedCookie", variable: "_swb")
        ]))

        XCTAssertNil(resolved)
        XCTAssertEqual(storage.read(key: ManagedIdentity.storageKey), "", "nothing is minted while inert")
    }

    func testResolver_failureIsNotMemoisedSoALaterCallRetries() {
        let resolver = ManagedIdentityResolver(storage: storage)
        var attempts = 0
        let load: IdentityConfigLoader = {
            attempts += 1
            if attempts == 1 {
                return Fail(error: KetchSDK.KetchError.requestError).eraseToAnyPublisher()
            }
            return Just(self.queryStringConfig).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        XCTAssertNil(resolve(resolver, loadConfig: load))
        XCTAssertNotNil(resolve(resolver, loadConfig: load), "a network blip must not stick for the process")
        XCTAssertEqual(attempts, 2)
    }

    func testResolver_lastResolvedSurvivesForRequestsWithoutAProperty() {
        let resolver = ManagedIdentityResolver(storage: storage)
        XCTAssertNil(resolver.lastResolved())

        let resolved = resolve(resolver, loadConfig: loader(queryStringConfig))
        XCTAssertEqual(resolver.lastResolved(), resolved)
    }

    func testResolver_clearAnswersCallersQueuedBehindAnInFlightFetch() {
        let resolver = ManagedIdentityResolver(storage: storage)
        let gate = PassthroughSubject<[String: KetchSDK.IdentityDefinition]?, Error>()

        var answered = false
        let done = expectation(description: "queued caller answered")
        resolver.resolve(
            organizationCode: "acme", propertyCode: "ios", loadConfig: { gate.eraseToAnyPublisher() }
        )
        .sink { _ in answered = true; done.fulfill() }
        .store(in: &cancellables)

        // Clearing cancels the fetch, so nothing else will ever complete this caller.
        resolver.clear()

        wait(for: [done], timeout: 2)
        XCTAssertTrue(answered)
    }

    func testResolver_clearDropsMemoAndStorage() {
        let resolver = ManagedIdentityResolver(storage: storage)
        let first = resolve(resolver, loadConfig: loader(queryStringConfig))

        resolver.clear()

        XCTAssertEqual(storage.read(key: ManagedIdentity.storageKey), "")
        XCTAssertEqual(storage.read(key: ManagedIdentity.mintedAtKey), "")
        XCTAssertNil(resolver.lastResolved())

        let second = resolve(resolver, loadConfig: loader(queryStringConfig))
        XCTAssertNotNil(second)
        XCTAssertNotEqual(first?.value, second?.value, "a memo left in place would hand back the cleared value")
    }
}
