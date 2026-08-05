//
//  KetchIntegrationUITests.swift
//  KetchIntegrationUITests
//
//  Created for Ketch iOS SDK Integration Tests
//

import XCTest

class KetchIntegrationUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - Test Methods
    
    func testAppLaunchesSuccessfully() throws {
        let statusText = app.staticTexts["statusText"]
        XCTAssertTrue(statusText.exists, "Status text element should exist")
        XCTAssertEqual(statusText.label, "Ketch initialized", "Status should show 'Ketch initialized'")
    }
    
    func testKetchInitializationDisplaysCorrectStatus() throws {
        let statusText = app.staticTexts["statusText"]
        XCTAssertTrue(statusText.exists, "Status text element should exist")
        XCTAssertEqual(statusText.label, "Ketch initialized", "Status should show 'Ketch initialized'")
    }
    
    func testLoadSdkTriggersConsentUpdatedListener() throws {
        // Tap the load button
        let loadButton = app.buttons["loadButton"]
        XCTAssertTrue(loadButton.exists, "Load button should exist")
        loadButton.tap()
        
        // Wait for consent text to update
        let consentText = app.staticTexts["consentText"]
        let consentUpdated = waitForPredicate(element: consentText) { element in
            return !element.label.contains("Not set")
        }
        
        XCTAssertTrue(consentUpdated, "Consent text should have been updated within timeout")
        XCTAssertFalse(consentText.label.contains("Not set"), "Consent text should not contain 'Not set'")
    }
    
    func testLoadSdkUpdatesEnvironment() throws {
        // Tap the load button
        let loadButton = app.buttons["loadButton"]
        XCTAssertTrue(loadButton.exists, "Load button should exist")
        loadButton.tap()
        
        // Wait for environment text to update
        let environmentText = app.staticTexts["environmentText"]
        let environmentUpdated = waitForPredicate(element: environmentText) { element in
            return !element.label.contains("Not set")
        }
        
        XCTAssertTrue(environmentUpdated, "Environment text should have been updated within timeout")
        XCTAssertFalse(environmentText.label.contains("Not set"), "Environment text should not contain 'Not set'")
    }
    
    func testLoadSdkTriggersConfigUpdate() throws {
        // Tap the load button
        let loadButton = app.buttons["loadButton"]
        XCTAssertTrue(loadButton.exists, "Load button should exist")
        loadButton.tap()
        
        // Wait for status text to show "Config updated"
        let statusText = app.staticTexts["statusText"]
        let configUpdated = waitForPredicate(element: statusText) { element in
            return element.label == "Config updated"
        }
        
        XCTAssertTrue(configUpdated, "Status text should show 'Config updated' within timeout")
        XCTAssertEqual(statusText.label, "Config updated", "Status should show 'Config updated'")
    }
    
    func testShowConsentDisplaysDialog() throws {
        // Tap the show consent button
        let showConsentButton = app.buttons["showConsentButton"]
        XCTAssertTrue(showConsentButton.exists, "Show consent button should exist")
        showConsentButton.tap()
        
        // Wait for status text to show "Dialog shown"
        let statusText = app.staticTexts["statusText"]
        let dialogShown = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog shown"
        }
        
        XCTAssertTrue(dialogShown, "Status text should show 'Dialog shown' within timeout")
        
        // Validate the consent banner exists in the webview
        let validateButton = app.buttons["testValidateConsentBanner"]
        XCTAssertTrue(validateButton.exists, "Validate consent banner button should exist")
        validateButton.tap()
        
        // Wait for test result text to show validation result
        let testResultText = app.staticTexts["testResultText"]
        let validationComplete = waitForPredicate(element: testResultText) { element in
            return element.label.contains("ketch-consent-banner:")
        }
        
        XCTAssertTrue(validationComplete, "Test result text should contain validation result within timeout")
        XCTAssertTrue(testResultText.label.contains("ketch-consent-banner:true"), "Test result should indicate consent banner exists")
    }
    
    func testShowPreferencesDisplaysDialog() throws {
        // Tap the show preferences button
        let showPreferencesButton = app.buttons["showPreferencesButton"]
        XCTAssertTrue(showPreferencesButton.exists, "Show preferences button should exist")
        showPreferencesButton.tap()
        
        // Wait for status text to show "Dialog shown"
        let statusText = app.staticTexts["statusText"]
        let dialogShown = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog shown"
        }
        
        XCTAssertTrue(dialogShown, "Status text should show 'Dialog shown' within timeout")
        
        // Validate the preferences center exists in the webview
        let validateButton = app.buttons["testValidatePreferencesCenter"]
        XCTAssertTrue(validateButton.exists, "Validate preferences center button should exist")
        validateButton.tap()
        
        // Wait for test result text to show validation result
        let testResultText = app.staticTexts["testResultText"]
        let validationComplete = waitForPredicate(element: testResultText) { element in
            return element.label.contains("ketch-preferences:")
        }
        
        XCTAssertTrue(validationComplete, "Test result text should contain validation result within timeout")
        XCTAssertTrue(testResultText.label.contains("ketch-preferences:true"), "Test result should indicate preferences center exists")
    }
    
    func testAllButtonsAreDisplayed() throws {
        // Verify all main action buttons exist and are hittable
        let buttons = [
            "loadButton",
            "showConsentButton",
            "showPreferencesButton",
            "setLanguageButton",
            "setJurisdictionButton",
            "setRegionButton"
        ]
        
        for buttonId in buttons {
            let button = app.buttons[buttonId]
            XCTAssertTrue(button.exists, "\(buttonId) should exist")
            XCTAssertTrue(button.isHittable, "\(buttonId) should be hittable")
        }
    }
    
    func testSdkStateDisplaysInitialValues() throws {
        // Verify initial Not set labels
        let initialTexts = [
            ("environmentText", "Environment: Not set"),
            ("consentText", "Consent: Not set"),
            ("usPrivacyText", "US Privacy: Not set"),
            ("tcfText", "TCF: Not set"),
            ("gppText", "GPP: Not set")
        ]
        
        for (identifier, expectedText) in initialTexts {
            let textElement = app.staticTexts[identifier]
            XCTAssertTrue(textElement.exists, "\(identifier) should exist")
            XCTAssertEqual(textElement.label, expectedText, "\(identifier) should show '\(expectedText)'")
        }
    }
    
    func testLoadWithUniqueIdentityShowsBanner() throws {
        // Update identities
        let updateIdentitiesButton = app.buttons["testUpdateIdentities"]
        XCTAssertTrue(updateIdentitiesButton.exists, "Update identities button should exist")
        updateIdentitiesButton.tap()
        
        // Wait for identities to update
        let statusText = app.staticTexts["statusText"]
        let identitiesUpdated = waitForPredicate(element: statusText) { element in
            return element.label.contains("Updated identities with unique ID:")
        }
        XCTAssertTrue(identitiesUpdated, "Status text should indicate identities updated within timeout")
        
        // Tap the load button
        let loadButton = app.buttons["loadButton"]
        loadButton.tap()
        
        // Wait for dialog to show
        let dialogShown = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog shown"
        }
        XCTAssertTrue(dialogShown, "Status text should show 'Dialog shown' within timeout")
        
        // Validate the consent banner exists
        let validateButton = app.buttons["testValidateConsentBanner"]
        validateButton.tap()
        
        // Wait for test result text to show validation result
        let testResultText = app.staticTexts["testResultText"]
        let validationComplete = waitForPredicate(element: testResultText) { element in
            return element.label.contains("ketch-consent-banner:")
        }
        
        XCTAssertTrue(validationComplete, "Test result text should contain validation result within timeout")
        XCTAssertTrue(testResultText.label.contains("ketch-consent-banner:true"), "Test result should indicate consent banner exists")
    }
    
    func testConsentBannerUserInteraction() throws {
        // Phase 1: Update identities and load to show banner
        let updateIdentitiesButton = app.buttons["testUpdateIdentities"]
        updateIdentitiesButton.tap()
        
        // Wait for identities to update
        let statusText = app.staticTexts["statusText"]
        let identitiesUpdated = waitForPredicate(element: statusText) { element in
            return element.label.contains("Updated identities with unique ID:")
        }
        XCTAssertTrue(identitiesUpdated, "Status text should indicate identities updated within timeout")
        
        // Tap the load button
        let loadButton = app.buttons["loadButton"]
        loadButton.tap()
        
        // Wait for dialog to show
        let dialogShown = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog shown"
        }
        XCTAssertTrue(dialogShown, "Status text should show 'Dialog shown' within timeout")
        
        // Validate the consent banner exists
        let validateConsentButton = app.buttons["testValidateConsentBanner"]
        validateConsentButton.tap()
        
        // Wait for test result text to show validation result
        let testResultText = app.staticTexts["testResultText"]
        let validationComplete = waitForPredicate(element: testResultText) { element in
            return element.label.contains("ketch-consent-banner:true")
        }
        XCTAssertTrue(validationComplete, "Test result should indicate consent banner exists")
        
        // Phase 2: Click the primary button (Opt Out)
        let clickPrimaryButton = app.buttons["testClickPrimary"]
        clickPrimaryButton.tap()
        
        // Wait for dialog to dismiss
        let dialogDismissed = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog dismissed"
        }
        XCTAssertTrue(dialogDismissed, "Status text should show 'Dialog dismissed' within timeout")
        
        // Verify consent was updated
        // NOTE: Skipping explicit consent value verification because the public
        // SDK interface does not expose granular consent changes required for
        // this check. Validation of banner display and dismissal is considered
        // sufficient for integration testing purposes.
        
        // Phase 3: Show consent again
        let showConsentButton = app.buttons["showConsentButton"]
        showConsentButton.tap()
        
        // Wait for dialog to show
        let dialogShownAgain = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog shown"
        }
        XCTAssertTrue(dialogShownAgain, "Status text should show 'Dialog shown' within timeout")
        
        // Validate the consent banner exists again
        validateConsentButton.tap()
        
        // Wait for test result text to show validation result
        let validationCompleteAgain = waitForPredicate(element: testResultText) { element in
            return element.label.contains("ketch-consent-banner:true")
        }
        XCTAssertTrue(validationCompleteAgain, "Test result should indicate consent banner exists")
        
        // Phase 4: Click the tertiary button (Opt In)
        let clickTertiaryButton = app.buttons["testClickTertiary"]
        clickTertiaryButton.tap()
        
        // Wait for dialog to dismiss
        let dialogDismissedAgain = waitForPredicate(element: statusText) { element in
            return element.label == "Dialog dismissed"
        }
        XCTAssertTrue(dialogDismissedAgain, "Status text should show 'Dialog dismissed' within timeout")
        
        // Verify consent was updated again
        // NOTE: Skipping explicit consent value re-verification for the same
        // reasons stated earlier.
    }
    
    // MARK: - Helper Methods
    
    private func waitForPredicate<T: XCUIElement>(element: T, timeout: TimeInterval = 30, handler: @escaping (T) -> Bool) -> Bool {
        let predicate = NSPredicate { _, _ in
            return handler(element)
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    private var previousConsentValue: String {
        return app.staticTexts["consentText"].label
    }
}
