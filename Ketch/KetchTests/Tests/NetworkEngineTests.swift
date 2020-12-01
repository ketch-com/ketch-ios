//
//  NetworkEngineTests.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

@testable import Ketch

class NetworkEngineTests: XCTestCase {

    let organizationCode = "foo"
    let applicationCode = "bar"

    func createNetworkEngine() -> (NetworkEngine, URLSessionMock, InMemoryCacheEngine) {
        let settings = Settings(organizationCode: organizationCode, applicationCode: applicationCode)
        let session = URLSessionMock()
        let cachingEngine = InMemoryCacheEngine()
        let engine = NetworkEngineImpl(settings: settings, session: session, cachingEngine: cachingEngine)
        return (engine, session, cachingEngine)
    }

    // MARK: - Common handling

    func testNetworkError() {
        let (engine, session, _) = createNetworkEngine()
        session.mockedError = NSError(domain: "urlsession", code: 404, userInfo: nil)
        let task = engine.getBootstrapConfiguration()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            guard let error = task.error else {
                XCTFail("Error is nil")
                return
            }

            guard case .requestError(let underline) = error else {
                XCTFail("Error is invalid")
                return
            }

            XCTAssertEqual(underline as NSError?, session.mockedError as NSError?)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testInvalidStatus300XError() {
        let (engine, session, _) = createNetworkEngine()
        session.mockedResponse = HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 301, httpVersion: nil, headerFields: nil)
        let task = engine.getBootstrapConfiguration()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            guard let error = task.error else {
                XCTFail("Error is nil")
                return
            }

            guard case .invalidStatusCode(let code) = error else {
                XCTFail("Error is invalid")
                return
            }

            XCTAssertEqual(code, 301)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testInvalidStatus400XError() {
        let (engine, session, _) = createNetworkEngine()
        session.mockedResponse = HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let task = engine.getBootstrapConfiguration()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            guard let error = task.error else {
                XCTFail("Error is nil")
                return
            }

            guard case .invalidStatusCode(let code) = error else {
                XCTFail("Error is invalid")
                return
            }

            XCTAssertEqual(code, 404)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testInvalidStatus500XError() {
        let (engine, session, _) = createNetworkEngine()
        session.mockedResponse = HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let task = engine.getBootstrapConfiguration()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            guard let error = task.error else {
                XCTFail("Error is nil")
                return
            }

            guard case .serverNotReachable = error else {
                XCTFail("Error is invalid")
                return
            }
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - BootstrapConfiguration

    func testGetBootstrapConfigurationGetCache() {
        let (engine, session, cachingEngine) = createNetworkEngine()
        session.mockedResponse = HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let cacheKey = "bootstrapConfiguration"
        cachingEngine.save(key: cacheKey, object: BootstrapConfiguration.mock())
        let task = engine.getBootstrapConfiguration()
        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            defer {
                expectation.fulfill()
            }

            guard case .cache(let cache) = result, let config = cache else {
                XCTFail("Cache is not used")
                return
            }

            // Validate Cache
            XCTAssertEqual(config.version, 1)
            XCTAssertEqual(config.organization?.code, "habu")
            XCTAssertEqual(config.application?.code, "sublimedaily")
            XCTAssertEqual(config.application?.name, "Sublime Daily")
            XCTAssertEqual(config.application?.platform, "WEB")
            XCTAssertEqual(config.environments?.count, 2)
            XCTAssertEqual(config.environments?[0].code, "production")
            XCTAssertEqual(config.environments?[0].pattern, "Ly9zdWJsaW1lZGFpbHkuY29t")
            XCTAssertEqual(config.environments?[0].hash, "4290636013626569096")
            XCTAssertEqual(config.environments?[1].code, "staging")
            XCTAssertEqual(config.environments?[1].pattern, "Ly9zdGFnZS5zdWJsaW1lZGFpbHkuY29t")
            XCTAssertEqual(config.environments?[1].hash, "5372302035981843260")
            XCTAssertEqual(config.policyScope?.defaultScopeCode, "gdpr")
            XCTAssertEqual(config.policyScope?.scopes?["GB"], "gdpr")
            XCTAssertEqual(config.policyScope?.scopes?["US-CA"], "ccpa")
            XCTAssertEqual(config.policyScope?.scopes?["US-GA"], "us_standard")
            XCTAssertEqual(config.policyScope?.scopes?["YT"], "gdpr")
            XCTAssertEqual(config.identities?["habu_cookie"]?.type, "window")
            XCTAssertEqual(config.identities?["habu_cookie"]?.variable, "window.__Habu.huid")
            XCTAssertEqual(config.scripts, ["https://cdn.b10s.io/transom/route/switchbit/semaphore/habu/semaphore.js"])
            XCTAssertEqual(config.services?.astrolabe, "https://cdn.b10s.io/astrolabe/")
            XCTAssertEqual(config.services?.gangplank, "https://cdn.b10s.io/gangplank/")
            XCTAssertEqual(config.services?.halyard, "https://cdn.b10s.io/transom/route/switchbit/halyard/habu/bundle.min.js")
            XCTAssertEqual(config.services?.supercargo, "https://cdn.b10s.io/supercargo/config/1/")
            XCTAssertEqual(config.services?.wheelhouse, "https://cdn.b10s.io/wheelhouse/")
            XCTAssertEqual(config.options?.localStorage, 1)
            XCTAssertEqual(config.options?.migration, 1)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetBootstrapConfiguration() {
        let (engine, session, cachingEngine) = createNetworkEngine()
        session.mockedJSON = GetBootstrapConfigurationMockRequest().json
        let task = engine.getBootstrapConfiguration()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "https://cdn.b10s.io/supercargo/config/1/\(self.organizationCode)/\(self.applicationCode)/boot.json")

            defer {
                expectation.fulfill()
            }

            // Validate Cache
            guard let config = cachingEngine.store.first?.value as? BootstrapConfiguration else {
                XCTFail("Cache is nil")
                return
            }
            XCTAssertEqual(config.version, 1)
            XCTAssertEqual(config.organization?.code, "habu")
            XCTAssertEqual(config.application?.code, "sublimedaily")
            XCTAssertEqual(config.application?.name, "Sublime Daily")
            XCTAssertEqual(config.application?.platform, "WEB")
            XCTAssertEqual(config.environments?.count, 2)
            XCTAssertEqual(config.environments?[0].code, "production")
            XCTAssertEqual(config.environments?[0].pattern, "Ly9zdWJsaW1lZGFpbHkuY29t")
            XCTAssertEqual(config.environments?[0].hash, "4290636013626569096")
            XCTAssertEqual(config.environments?[1].code, "staging")
            XCTAssertEqual(config.environments?[1].pattern, "Ly9zdGFnZS5zdWJsaW1lZGFpbHkuY29t")
            XCTAssertEqual(config.environments?[1].hash, "5372302035981843260")
            XCTAssertEqual(config.policyScope?.defaultScopeCode, "gdpr")
            XCTAssertEqual(config.policyScope?.scopes?["GB"], "gdpr")
            XCTAssertEqual(config.policyScope?.scopes?["US-CA"], "ccpa")
            XCTAssertEqual(config.policyScope?.scopes?["US-GA"], "us_standard")
            XCTAssertEqual(config.policyScope?.scopes?["YT"], "gdpr")
            XCTAssertEqual(config.identities?["habu_cookie"]?.type, "window")
            XCTAssertEqual(config.identities?["habu_cookie"]?.variable, "window.__Habu.huid")
            XCTAssertEqual(config.scripts, ["https://cdn.b10s.io/transom/route/switchbit/semaphore/habu/semaphore.js"])
            XCTAssertEqual(config.services?.astrolabe, "https://cdn.b10s.io/astrolabe/")
            XCTAssertEqual(config.services?.gangplank, "https://cdn.b10s.io/gangplank/")
            XCTAssertEqual(config.services?.halyard, "https://cdn.b10s.io/transom/route/switchbit/halyard/habu/bundle.min.js")
            XCTAssertEqual(config.services?.supercargo, "https://cdn.b10s.io/supercargo/config/1/")
            XCTAssertEqual(config.services?.wheelhouse, "https://cdn.b10s.io/wheelhouse/")
            XCTAssertEqual(config.options?.localStorage, 1)
            XCTAssertEqual(config.options?.migration, 1)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Configuration

    func testGetFullConfigrationMissedSupercargoHost() {
        let (engine, _, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.supercargo = nil
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "", countryCode: "", regionCode: "", languageCode: "")
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetFullConfigurationValidationError.supercargoHostNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetFullConfigrationInvalidSupercargoHost() {
        let (engine, _, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.supercargo = "😀"
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "", countryCode: "", regionCode: "", languageCode: "")
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetFullConfigurationValidationError.supercargoHostInvalid = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetFullConfigrationMissedEnvironment() {
        let (engine, _, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.environments = []
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "123", countryCode: "", regionCode: "", languageCode: "")
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetFullConfigurationValidationError.cannotFindEnvironment(let env) = underline else {
            XCTFail("Error is invalid")
            return
        }

        XCTAssertEqual(env, "123")
    }

    func testGetFullConfigrationMissedEnvironmentHash() {
        let (engine, _, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.environments = [Environment(code: "123", pattern: "MTIz", hash: nil)]
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "123", countryCode: "", regionCode: "", languageCode: "")
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetFullConfigurationValidationError.environmentMissedHash(let env) = underline else {
            XCTFail("Error is invalid")
            return
        }

        XCTAssertEqual(env, "123")
    }

    func testGetFullConfigurationGetCache() {
        let (engine, session, cachingEngine) = createNetworkEngine()
        session.mockedResponse = HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.supercargo = "http://example.com"
        bootstrapConfiguration.environments = [Environment(code: "123", pattern: "MTIz", hash: "456")]
        bootstrapConfiguration.policyScope?.scopes = ["US-OO": "qwerty"]
        let cacheKey = "configuration_6a18bea5916d29a6d18a8f19b6f5b4f6294237977f1a76187a8d6ee64a704fa8"
        cachingEngine.save(key: cacheKey, object: Configuration.mock())
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "123", countryCode: "US", regionCode: "OO", languageCode: "BAR")
        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            defer {
                expectation.fulfill()
            }
            guard case .cache(let cache) = result, let config = cache else {
                XCTFail("Cache is not used")
                return
            }

            // Validate Cache
            XCTAssertEqual(config.version, 1)
            XCTAssertEqual(config.language, "en-US")
            XCTAssertEqual(config.organization?.code, "habu")
            XCTAssertEqual(config.application?.code, "sublimedaily")
            XCTAssertEqual(config.application?.name, "Sublime Daily")
            XCTAssertEqual(config.application?.platform, "WEB")
            XCTAssertEqual(config.environments?.count, 2)
            XCTAssertEqual(config.environments?[0].code, "production")
            XCTAssertEqual(config.environments?[0].hash, "4290636013626569096")
            XCTAssertEqual(config.environments?[1].code, "staging")
            XCTAssertEqual(config.environment?.code, "production")
            XCTAssertEqual(config.environment?.hash, "4290636013626569096")
            XCTAssertEqual(config.identities?["habu_cookie"]?.type, "window")
            XCTAssertEqual(config.identities?["habu_cookie"]?.variable, "window.__Habu.huid")
            XCTAssertEqual(config.deployment?.code, "habu_dep")
            XCTAssertEqual(config.deployment?.version, 1)
            XCTAssertEqual(config.policyScope?.defaultScopeCode, "gdpr")
            XCTAssertEqual(config.policyScope?.code, "ccpa")
            XCTAssertEqual(config.privacyPolicy?.code, "habupp")
            XCTAssertEqual(config.privacyPolicy?.version, 1)
            XCTAssertEqual(config.privacyPolicy?.url, "https://habu.com/privacypolicy")
            XCTAssertEqual(config.termsOfService?.code, "habutou")
            XCTAssertEqual(config.termsOfService?.version, 1)
            XCTAssertEqual(config.termsOfService?.url, "https://habu.com/tou")
            XCTAssertEqual(config.rights?.count, 3)
            XCTAssertEqual(config.rights?[0].code, "portability")
            XCTAssertEqual(config.rights?[0].name, "Portability")
            XCTAssertEqual(config.rights?[0].description, "Right to have all data provided to you.")
            XCTAssertEqual(config.regulations, ["ccpa"])
            XCTAssertEqual(config.purposes?.count, 8)
            XCTAssertEqual(config.purposes?[0].code, "identity_management")
            XCTAssertEqual(config.purposes?[0].name, "User ID Linking")
            XCTAssertEqual(config.purposes?[0].description, "Data can be used to bridge commonality of audience traits at a granular level.")
            XCTAssertEqual(config.purposes?[0].legalBasisCode, "disclosure")
            XCTAssertEqual(config.purposes?[0].requiresPrivacyPolicy, true)
            XCTAssertEqual(config.services?.astrolabe, "https://cdn.b10s.io/astrolabe/")
            XCTAssertEqual(config.services?.gangplank, "https://cdn.b10s.io/gangplank/")
            XCTAssertEqual(config.services?.halyard, "https://cdn.b10s.io/transom/route/switchbit/halyard/habu/bundle.min.js")
            XCTAssertEqual(config.services?.supercargo, "https://cdn.b10s.io/supercargo/config/1/")
            XCTAssertEqual(config.services?.wheelhouse, "https://cdn.b10s.io/wheelhouse/")
            XCTAssertEqual(config.options?.localStorage, 1)
            XCTAssertEqual(config.options?.migration, 1)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetFullConfigurationProductionEnvironment() {
        let (engine, session, _) = createNetworkEngine()
        session.mockedJSON = GetFullConfigurationMockRequest().json
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.supercargo = "http://example.com"
        bootstrapConfiguration.environments = [Environment(code: "production", pattern: nil, hash: "789")]
        bootstrapConfiguration.policyScope?.scopes = ["US-OO": "qwerty"]
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "123", countryCode: "US", regionCode: "OO", languageCode: "BAR")
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://example.com/\(self.organizationCode)/\(self.applicationCode)/production/789/qwerty/BAR/config.json")

            expectation.fulfill()
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetFullConfigurationDefaultPolicyScope() {
        let (engine, session, _) = createNetworkEngine()
        session.mockedJSON = GetFullConfigurationMockRequest().json
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.supercargo = "http://example.com"
        bootstrapConfiguration.environments = [Environment(code: "123", pattern: "MTIz", hash: "456")]
        bootstrapConfiguration.policyScope?.scopes = [:]
        bootstrapConfiguration.policyScope?.defaultScopeCode = "boomer"
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "123", countryCode: "US", regionCode: "OO", languageCode: "BAR")
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://example.com/\(self.organizationCode)/\(self.applicationCode)/123/456/boomer/BAR/config.json")

            expectation.fulfill()
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetFullConfiguration() {
        let (engine, session, cachingEngine) = createNetworkEngine()
        session.mockedJSON = GetFullConfigurationMockRequest().json
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.supercargo = "http://example.com"
        bootstrapConfiguration.environments = [Environment(code: "123", pattern: "MTIz", hash: "456")]
        bootstrapConfiguration.policyScope?.scopes = ["US-OO": "qwerty"]
        let task = engine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: "123", countryCode: "US", regionCode: "OO", languageCode: "BAR")
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://example.com/\(self.organizationCode)/\(self.applicationCode)/123/456/qwerty/BAR/config.json")

            defer {
                expectation.fulfill()
            }

            // Validate Cache
            guard let config = cachingEngine.store.first?.value as? Configuration else {
                XCTFail("Cache is nil")
                return
            }
            XCTAssertEqual(config.version, 1)
            XCTAssertEqual(config.language, "en-US")
            XCTAssertEqual(config.organization?.code, "habu")
            XCTAssertEqual(config.application?.code, "sublimedaily")
            XCTAssertEqual(config.application?.name, "Sublime Daily")
            XCTAssertEqual(config.application?.platform, "WEB")
            XCTAssertEqual(config.environments?.count, 2)
            XCTAssertEqual(config.environments?[0].code, "production")
            XCTAssertEqual(config.environments?[0].hash, "4290636013626569096")
            XCTAssertEqual(config.environments?[1].code, "staging")
            XCTAssertEqual(config.environment?.code, "production")
            XCTAssertEqual(config.environment?.hash, "4290636013626569096")
            XCTAssertEqual(config.identities?["habu_cookie"]?.type, "window")
            XCTAssertEqual(config.identities?["habu_cookie"]?.variable, "window.__Habu.huid")
            XCTAssertEqual(config.deployment?.code, "habu_dep")
            XCTAssertEqual(config.deployment?.version, 1)
            XCTAssertEqual(config.policyScope?.defaultScopeCode, "gdpr")
            XCTAssertEqual(config.policyScope?.code, "ccpa")
            XCTAssertEqual(config.privacyPolicy?.code, "habupp")
            XCTAssertEqual(config.privacyPolicy?.version, 1)
            XCTAssertEqual(config.privacyPolicy?.url, "https://habu.com/privacypolicy")
            XCTAssertEqual(config.termsOfService?.code, "habutou")
            XCTAssertEqual(config.termsOfService?.version, 1)
            XCTAssertEqual(config.termsOfService?.url, "https://habu.com/tou")
            XCTAssertEqual(config.rights?.count, 3)
            XCTAssertEqual(config.rights?[0].code, "portability")
            XCTAssertEqual(config.rights?[0].name, "Portability")
            XCTAssertEqual(config.rights?[0].description, "Right to have all data provided to you.")
            XCTAssertEqual(config.regulations, ["ccpa"])
            XCTAssertEqual(config.purposes?.count, 8)
            XCTAssertEqual(config.purposes?[0].code, "identity_management")
            XCTAssertEqual(config.purposes?[0].name, "User ID Linking")
            XCTAssertEqual(config.purposes?[0].description, "Data can be used to bridge commonality of audience traits at a granular level.")
            XCTAssertEqual(config.purposes?[0].legalBasisCode, "disclosure")
            XCTAssertEqual(config.purposes?[0].requiresPrivacyPolicy, true)
            XCTAssertEqual(config.services?.astrolabe, "https://cdn.b10s.io/astrolabe/")
            XCTAssertEqual(config.services?.gangplank, "https://cdn.b10s.io/gangplank/")
            XCTAssertEqual(config.services?.halyard, "https://cdn.b10s.io/transom/route/switchbit/halyard/habu/bundle.min.js")
            XCTAssertEqual(config.services?.supercargo, "https://cdn.b10s.io/supercargo/config/1/")
            XCTAssertEqual(config.services?.wheelhouse, "https://cdn.b10s.io/wheelhouse/")
            XCTAssertEqual(config.options?.localStorage, 1)
            XCTAssertEqual(config.options?.migration, 1)
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Location

    func testGetLocationMissedHost() {
        let (engine, _, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.astrolabe = nil
        let task = engine.getLocation(bootstrapConfiguration: bootstrapConfiguration)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetLocationValidationError.astrolabeHostNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetLocationInvalidHost() {
        let (engine, _, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.astrolabe = "😀"
        let task = engine.getLocation(bootstrapConfiguration: bootstrapConfiguration)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetLocationValidationError.astrolabeHostInvalid = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetLocation() {
        let (engine, session, _) = createNetworkEngine()
        var bootstrapConfiguration = BootstrapConfiguration.mock()
        bootstrapConfiguration.services?.astrolabe = "http://justexample.com"
        session.mockedJSON = GetLocationMockRequest().json
        let task = engine.getLocation(bootstrapConfiguration: bootstrapConfiguration)
        task.schedule()

        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://justexample.com")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - GetConsentStatus

    func testGetConsentStatusMissedHost() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = nil
        let task = engine.getConsentStatus(configuration: configuration, identities: [:], purposes: [:])
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetConsentStatusValidationError.wheelhouseHostNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetConsentStatusInvalidHost() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "😀"
        let task = engine.getConsentStatus(configuration: configuration, identities: [:], purposes: [:])
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetConsentStatusValidationError.wheelhouseHostInvalid = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetConsentStatusMissedIndentities() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.getConsentStatus(configuration: configuration, identities: [:], purposes: [:])
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetConsentStatusValidationError.noIdentities = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetConsentStatusMissedActivities() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: [:])
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetConsentStatusValidationError.noPurposes = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetConsentStatusMissedActivity() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"])
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetConsentStatusValidationError.purposeIsNotFoundInConfig(let activity) = underline else {
            XCTFail("Error is invalid")
            return
        }

        XCTAssertEqual(activity, "foo")
    }

    func testGetConsentStatusMissedEnvironmentCode() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.environment?.code = nil
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: "bar", requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]
        let task = engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"])
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case GetConsentStatusValidationError.environmentCodeNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testGetConsentStatusGetCache() {
        let (engine, session, cachingEngine) = createNetworkEngine()
        session.mockedResponse = HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: nil, requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]
        let task = engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"])

        let cacheKey = "consentStatus_b80d5fac2e4c6d07d2d8e3b5a2470b488eb58297fa29d501de8846575c94c5b7"
        cachingEngine.save(key: cacheKey, object: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")])

        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            defer {
                expectation.fulfill()
            }
            guard case .cache(let cache) = result, let map = cache else {
                XCTFail("Cache is not used")
                return
            }

            XCTAssertEqual(map.count, 1)
            XCTAssertEqual(map["foo"], ConsentStatus(allowed: true, legalBasisCode: "bar"))
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetConsentStatus() {
        let (engine, session, cachingEngine) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: nil, requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]
        session.mockedJSON = #"""
        {
            "purposes": {
                "foo": {
                  "allowed": "true"
                }
            }
        }
        """#
        let task = engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"])
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://test.com/consent/\(self.organizationCode)/get")

            // Validate body of request
            guard let body = session.request?.httpBody, let map = try? JSONSerialization.jsonObject(with: body, options: .init()) as? [String: Any] else {
                XCTFail("Error is invalid")
                return
            }

            XCTAssertEqual(map["applicationCode"] as? String, self.applicationCode)
            XCTAssertEqual(map["applicationEnvironmentCode"] as? String, "testEnv")
            XCTAssertEqual(map["identities"] as? [String], [
                "srn:::::\(self.organizationCode):id/1/2"
            ])
            XCTAssertEqual(map["purposes"] as? [String: [String: String]], [
                "foo": [
                    "legalBasisCode": "bar"
                ]
            ])

            // Validate cache
            guard let cache = cachingEngine.store.first?.value as? [String: ConsentStatus] else {
                XCTFail("Cache is nil")
                return
            }

            XCTAssertEqual(cache.count, 1)
            XCTAssertEqual(cache["foo"], ConsentStatus(allowed: true, legalBasisCode: "bar"))
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - SetConsentStatus

    func testSetConsentStatusMissedHost() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = nil
        let task = engine.setConsentStatus(configuration: configuration, identities: [:], consents: [:], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.wheelhouseHostNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testSetConsentStatusInvalidHost() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "😀"
        let task = engine.setConsentStatus(configuration: configuration, identities: [:], consents: [:], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.wheelhouseHostInvalid = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testSetConsentStatusMissedIndentities() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.setConsentStatus(configuration: configuration, identities: [:], consents: [:], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.noIdentities = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testSetConsentStatusMissedActivities() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: [:], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.noConsents = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testSetConsentStatusMissedActivity() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.purposeIsNotFoundInConfig(let activity) = underline else {
            XCTFail("Error is invalid")
            return
        }

        XCTAssertEqual(activity, "foo")
    }

    func testSetConsentStatusMissedEnvironmentCode() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.environment?.code = nil
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: "bar", requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]
        let task = engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.environmentCodeNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testSetConsentStatusMissedPolicyScopeCode() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = nil
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: "bar", requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]
        let task = engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always)
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case SetConsentStatusValidationError.policyScopeCodeNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testSetConsentStatus() {
        let (engine, session, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = "testPolicyScope"
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: nil, requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]
        session.mockedJSON = "{}"
        let task = engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always)
        task.schedule()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://test.com/consent/\(self.organizationCode)/update")

            guard let body = session.request?.httpBody, let map = try? JSONSerialization.jsonObject(with: body, options: .init()) as? [String: Any] else {
                XCTFail("Error is invalid")
                return
            }

            XCTAssertEqual(map["applicationCode"] as? String, self.applicationCode)
            XCTAssertEqual(map["applicationEnvironmentCode"] as? String, "testEnv")
            XCTAssertEqual(map["policyScopeCode"] as? String, "testPolicyScope")
            XCTAssertEqual(map["migrationOption"] as? Int, 4)
            XCTAssertEqual(map["identities"] as? [String], [
                "srn:::::\(self.organizationCode):id/1/2"
            ])
            XCTAssertEqual(map["purposes"] as? [String: [String: String]], [
                "foo": [
                    "legalBasisCode": "bar",
                    "allowed": "true"
                ]
            ])
        }
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Invoke Rights

    func testInvokeRightsMissedHost() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.gangplank = nil
        let task = engine.invokeRights(configuration: configuration, identities: [:], rights: [], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.gangplankHostNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testInvokeRightsInvalidHost() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.gangplank = "😀"
        let task = engine.invokeRights(configuration: configuration, identities: [:], rights: [], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.gangplankHostInvalid = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testInvokeRightsMissedIndentities() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.invokeRights(configuration: configuration, identities: [:], rights: [], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.noIdentities = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testInvokeRightsMissedActivities() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.invokeRights(configuration: configuration, identities: ["1":"2"], rights: [], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.noRights = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testInvokeRightsMissedActivity() {
        let (engine, _, _) = createNetworkEngine()
        let configuration = Configuration.mock()
        let task = engine.invokeRights(configuration: configuration, identities: ["1":"2"], rights: ["abc"], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.rightIsNotFoundInConfig(let activity) = underline else {
            XCTFail("Error is invalid")
            return
        }

        XCTAssertEqual(activity, "abc")
    }

    func testInvokeRightsEnvironmentCode() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.environment?.code = nil
        configuration.rights = [
            Right(code: "abc", name: "AbC", description: "")
        ]
        let task = engine.invokeRights(configuration: configuration, identities: ["1":"2"], rights: ["abc"], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.environmentCodeNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testInvokeRightsMissedPolicyScopeCode() {
        let (engine, _, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = nil
        configuration.rights = [
            Right(code: "abc", name: "AbC", description: "")
        ]
        let task = engine.invokeRights(configuration: configuration, identities: ["1":"2"], rights: ["abc"], userData: UserData(email: "a@b.c"))
        task.schedule()

        guard let error = task.error else {
            XCTFail("Error is nil")
            return
        }

        guard case .validationError(let underline) = error else {
            XCTFail("Error is invalid")
            return
        }

        guard case InvokeRightsValidationError.policyScopeCodeNotSpecified = underline else {
            XCTFail("Error is invalid")
            return
        }
    }

    func testInvokeRights() {
        let (engine, session, _) = createNetworkEngine()
        var configuration = Configuration.mock()
        configuration.services?.gangplank = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = "testPolicyScope"
        configuration.rights = [
            Right(code: "abc", name: "AbC", description: "")
        ]
        session.mockedJSON = "{}"
        let task = engine.invokeRights(configuration: configuration, identities: ["1":"2"], rights: ["abc"], userData: UserData(email: "a@b.c"))
        task.schedule()
        let expectation = self.expectation(description: "response")
        task.onComplete = {
            defer {
                expectation.fulfill()
            }

            // No errors
            XCTAssertNil(task.error)

            // Validate URL
            XCTAssertEqual(session.request?.url?.absoluteString, "http://test.com/rights/\(self.organizationCode)/invoke")

            // Validate request body
            guard let body = session.request?.httpBody, let map = try? JSONSerialization.jsonObject(with: body, options: .init()) as? [String: Any] else {
                XCTFail("Error is invalid")
                return
            }

            XCTAssertEqual(map["applicationCode"] as? String, self.applicationCode)
            XCTAssertEqual(map["applicationEnvironmentCode"] as? String, "testEnv")
            XCTAssertEqual(map["policyScopeCode"] as? String, "testPolicyScope")
            XCTAssertEqual(map["rightsEmail"] as? String, "a@b.c")
            XCTAssertEqual(map["identities"] as? [String], [
                "srn:::::\(self.organizationCode):id/1/2"
            ])
            XCTAssertEqual(map["rightCodes"] as? [String], ["abc"])
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
