import XCTest
@testable import KetchSDK

final class TriggerValidationTests: XCTestCase {
    func testValidFunctionName_lettersDigitsUnderscoreDotDash() {
        XCTAssertTrue(KetchUI.isValidTriggerFunctionName("myFunction_1.name-2"))
    }

    func testValidFunctionName_singleCharacter() {
        XCTAssertTrue(KetchUI.isValidTriggerFunctionName("a"))
    }

    func testInvalidFunctionName_empty() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName(""))
    }

    func testInvalidFunctionName_blankWhitespace() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName(" "))
    }

    func testInvalidFunctionName_containsSpace() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("my function"))
    }

    func testInvalidFunctionName_containsSpecialCharacter() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("my/function"))
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("my'function"))
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("<script>"))
    }

    func testTriggerNameRawValue_customMatchesJSShape() {
        XCTAssertEqual(TriggerName.custom.rawValue, "custom")
    }
}
