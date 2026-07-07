import XCTest

final class TackleBoxLogUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddItemFlow() {
        app.buttons["addItemButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("UI Test Item")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Item"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<10 {
            let addButton = app.buttons["addItemButton"]
            if addButton.exists { addButton.tap() }
            let nameField = app.textFields["nameField"]
            if nameField.waitForExistence(timeout: 1) {
                nameField.tap()
                nameField.typeText("Item \(i)")
                app.buttons["saveButton"].tap()
            }
        }
        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 2) || app.buttons["paywallDismissButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addItemButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Tap Outside Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Catch Log"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testCancelAddItem() {
        app.buttons["addItemButton"].tap()
        XCTAssertTrue(app.buttons["cancelButton"].waitForExistence(timeout: 2))
        app.buttons["cancelButton"].tap()
        XCTAssertFalse(app.textFields["nameField"].exists)
    }
}
