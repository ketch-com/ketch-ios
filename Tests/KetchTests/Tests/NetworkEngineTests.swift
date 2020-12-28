//
//  NetworkEngineTests.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

import NIO
import GRPC

@testable import Ketch

class NetworkEngineTests: XCTestCase {
    private let organizationCode = "foo"
    private let applicationCode = "bar"

    private struct StubError: Error {}

    private func makeNetworkEngine(client: Mobile_MobileClientProtocol, cacheEngine: CacheEngine = InMemoryCacheEngine()) -> NetworkEngineGRPC {
        let settings = Settings(organizationCode: organizationCode, applicationCode: applicationCode)
        return NetworkEngineGRPCImpl(settings: settings, cachingEngine: cacheEngine, client: client)
    }

    // MARK: - Configuration

    func testGetFullConfigrationGRPCError() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeGetConfigurationResponseStream()
        let engine = makeNetworkEngine(client: client)

        let expectation = self.expectation(description: "response")

        engine.getFullConfiguration(environmentCode: "123", countryCode: "US", regionCode: "NY", ip: "", languageCode: "") { (result) in
            defer {
                expectation.fulfill()
            }

            guard case .failure(let error) = result else {
                XCTFail("Wrong response")
                return
            }

            guard case .grpc(let statusCode, let message) = error else {
                XCTFail("Wrong response")
                return
            }

            XCTAssertTrue(statusCode == GRPCStatus.Code.cancelled.rawValue)
            XCTAssertTrue(message == "Test")
        }

        let grpcStatus = GRPCStatus(code: .cancelled, message: "Test")
        XCTAssertNoThrow(try stream.sendError(grpcStatus))
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetFullConfigrationError() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeGetConfigurationResponseStream()
        let engine = makeNetworkEngine(client: client)

        let expectation = self.expectation(description: "response")

        engine.getFullConfiguration(environmentCode: "123", countryCode: "US", regionCode: "NY", ip: "", languageCode: "") { (result) in
            defer {
                expectation.fulfill()
            }

            guard case .failure(let error) = result else {
                XCTFail("Wrong response")
                return
            }

            guard case .other(let underlinedError) = error else {
                XCTFail("Wrong response")
                return
            }

            XCTAssertTrue(underlinedError is StubError)
        }

        XCTAssertNoThrow(try stream.sendError(StubError()))
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetFullConfigurationGetCache() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeGetConfigurationResponseStream()
        let cachingEngine = InMemoryCacheEngine()
        let engine = makeNetworkEngine(client: client, cacheEngine: cachingEngine)

        let cacheKey = "configuration_2d000dd923e3954178a47eb37a1955681f0bf4f0b179ade2c282e8fac741fb00"
        cachingEngine.save(key: cacheKey, object: Configuration.mock())

        let expectation = self.expectation(description: "response")

        engine.getFullConfiguration(environmentCode: "123", countryCode: "US", regionCode: "OO", ip: "", languageCode: "BAR") { (result) in
            defer {
                expectation.fulfill()
            }
            guard case .cache(let cache) = result, let config = cache else {
                XCTFail("Cache is not used")
                return
            }

            // Validate Cache
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

        XCTAssertNoThrow(try stream.sendError(StubError()))
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetFullConfiguration() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeGetConfigurationResponseStream()
        let cachingEngine = InMemoryCacheEngine()
        let engine = makeNetworkEngine(client: client, cacheEngine: cachingEngine)
        let response = Configuration.mock().raw

        let expectation = self.expectation(description: "response")

        engine.getFullConfiguration(environmentCode: "123", countryCode: "countryCode", regionCode: "regionCode", ip: "", languageCode: "BAR") { (result) in
            defer {
                expectation.fulfill()
            }

            guard case .success(_) = result else {
                XCTFail("Wrong response")
                return
            }

            // Validate Cache
            guard let config = cachingEngine.store.first?.value as? Configuration else {
                XCTFail("Cache is nil")
                return
            }

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

        XCTAssertNoThrow(try stream.sendMessage(response))
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - GetConsentStatus

    func testGetConsentStatusMissedIndentities() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()

        engine.getConsentStatus(configuration: configuration, identities: [:], purposes: [:]) { result in
            guard case .failure(let error) = result else {
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
    }

    func testGetConsentStatusMissedActivities() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()

        engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: [:]) { result in
            guard case .failure(let error) = result else {
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
    }

    func testGetConsentStatusMissedActivity() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()

        engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"]) { result in
            guard case .failure(let error) = result else {
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
    }

    func testGetConsentStatusMissedEnvironmentCode() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.environment?.code = nil
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: "bar", requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]

        engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"]) { result in
            guard case .failure(let error) = result else {
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
    }

    func testGetConsentStatusGetCache() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeGetConsentResponseStream()
        let cache = InMemoryCacheEngine()
        let engine = makeNetworkEngine(client: client, cacheEngine: cache)

        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: nil, requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]

        let cacheKey = "consentStatus_b80d5fac2e4c6d07d2d8e3b5a2470b488eb58297fa29d501de8846575c94c5b7"
        cache.save(key: cacheKey, object: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")])

        let expectation = self.expectation(description: "response")

        engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"]) { result in
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

        XCTAssertNoThrow(try stream.sendError(StubError()))
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetConsentStatus() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeGetConsentResponseStream()
        let cache = InMemoryCacheEngine()
        let engine = makeNetworkEngine(client: client, cacheEngine: cache)

        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: nil, requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]

        let response = Mobile_GetConsentResponse.with {
            $0.consents = [Mobile_Consent.with {
                $0.purpose = "foo"
                $0.legalBasis = "Legal Basis"
                $0.allowed = true
            }]
        }

        let expectation = self.expectation(description: "response")
        engine.getConsentStatus(configuration: configuration, identities: ["1":"2"], purposes: ["foo":"bar"]) { (result) in
            defer {
                expectation.fulfill()
            }

            guard case .success(let consents) = result else {
                XCTFail("Wrong response")
                return
            }

            guard consents?.count == 1, let consent = consents?["foo"] else {
                XCTFail("Wrong response")
                return
            }

            XCTAssertTrue(consent.allowed == true)
            XCTAssertEqual(consent.legalBasisCode, "Legal Basis")

            let key = "consentStatus_b80d5fac2e4c6d07d2d8e3b5a2470b488eb58297fa29d501de8846575c94c5b7"

            guard
                let cachedConsents: [String: ConsentStatus]? = cache.retrieve(key: key),
                cachedConsents?.count == 1,
                let cachedConsent = cachedConsents?["foo"] else {
                XCTFail("Wrong cache")
                return
            }

            XCTAssertEqual(consent, cachedConsent)
         }

        XCTAssertNoThrow(try stream.sendMessage(response))
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - SetConsentStatus

    func testSetConsentStatusMissedIndentities() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()

        engine.setConsentStatus(configuration: configuration, identities: [:], consents: [:], migrationOption: .always) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testSetConsentStatusMissedActivities() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()

        engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: [:], migrationOption: .always) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testSetConsentStatusMissedActivity() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()

        engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testSetConsentStatusMissedEnvironmentCode() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.environment?.code = nil
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: "bar", requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]

        engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testSetConsentStatusMissedPolicyScopeCode() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = nil
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: "bar", requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]

        engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testSetConsentStatus() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeSetConsentResponseStream()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.services?.wheelhouse = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = "testPolicyScope"
        configuration.organization?.name = "Organization"
        configuration.purposes = [
            Purpose(code: "foo", name: nil, description: nil, legalBasisCode: nil, requiresPrivacyPolicy: nil, requiresOptIn: nil, allowsOptOut: nil)
        ]

        let response = Mobile_SetConsentResponse.with {_ in }

        let expectation = self.expectation(description: "response")
        engine.setConsentStatus(configuration: configuration, identities: ["1":"2"], consents: ["foo": ConsentStatus(allowed: true, legalBasisCode: "bar")], migrationOption: .always) { (result) in
            defer {
                expectation.fulfill()
            }

            guard case .success = result else {
                XCTFail("Wrong response")
                return
            }
        }

        XCTAssertNoThrow(try stream.sendMessage(response))
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Invoke Rights

    func testInvokeRightsMissedIndentities() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()
        let userData = UserData(email: "a@b.c", first: "first", last: "last", country: "country", region: "region")

        engine.invokeRight(configuration: configuration, identities: [:], right: "rightCode", userData: userData) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testInvokeRightsMissedActivity() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)
        let configuration = Configuration.mock()
        let userData = UserData(email: "a@b.c", first: "first", last: "last", country: "country", region: "region")

        engine.invokeRight(configuration: configuration, identities: ["1":"2"], right: "abc", userData: userData) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testInvokeRightsEnvironmentCode() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.environment?.code = nil
        configuration.rights = [
            Right(code: "abc", name: "AbC", description: "")
        ]

        let userData = UserData(email: "a@b.c", first: "first", last: "last", country: "country", region: "region")

        engine.invokeRight(configuration: configuration, identities: ["1":"2"], right: "abc", userData: userData) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testInvokeRightsMissedPolicyScopeCode() {
        let client = Mobile_MobileTestClient()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = nil
        configuration.rights = [
            Right(code: "abc", name: "AbC", description: "")
        ]

        let userData = UserData(email: "a@b.c", first: "first", last: "last", country: "country", region: "region")

        engine.invokeRight(configuration: configuration, identities: ["1":"2"], right: "abc", userData: userData) { (result) in
            guard case .failure(let error) = result else {
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
    }

    func testInvokeRights() {
        let client = Mobile_MobileTestClient()
        let stream = client.makeInvokeRightResponseStream()
        let engine = makeNetworkEngine(client: client)

        var configuration = Configuration.mock()
        configuration.services?.gangplank = "http://test.com"
        configuration.environment?.code = "testEnv"
        configuration.policyScope?.code = "testPolicyScope"
        configuration.organization?.name = "Organization"
        configuration.rights = [
            Right(code: "abc", name: "AbC", description: "")
        ]

        let response = Mobile_InvokeRightResponse.with { _ in }
        let userData = UserData(email: "a@b.c", first: "first", last: "last", country: "country", region: "region")

        let expectation = self.expectation(description: "response")
        engine.invokeRight(configuration: configuration, identities: ["1":"2"], right: "abc", userData: userData) { (result) in
            defer {
                expectation.fulfill()
            }

            guard case .success = result else {
                XCTFail("Wrong response")
                return
            }
        }

        XCTAssertNoThrow(try stream.sendMessage(response))
        wait(for: [expectation], timeout: 5.0)
    }
}
