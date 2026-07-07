import XCTest
@testable import TackleBoxLog

@MainActor
final class TackleBoxLogTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testSeedItemsBelowFreeLimit() {
        let seeded = Store.seedItems()
        XCTAssertLessThan(seeded.count, store.freeItemLimit, "Seed count must stay under the free limit")
    }

    func testAddItemSucceedsUnderLimit() {
        let item = Item(name: "Test Item", primaryField: "A", secondaryField: "B")
        let added = store.addItem(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testAddItemFailsAtLimitWhenFree() {
        for i in 0..<store.freeItemLimit {
            store.addItem(Item(name: "Item \(i)", primaryField: "A", secondaryField: "B"))
        }
        XCTAssertFalse(store.canAddItem)
        let added = store.addItem(Item(name: "Overflow", primaryField: "A", secondaryField: "B"))
        XCTAssertFalse(added)
        XCTAssertEqual(store.items.count, store.freeItemLimit)
    }

    func testAddItemUnlimitedWhenPro() {
        store.isPro = true
        for i in 0..<(store.freeItemLimit + 5) {
            store.addItem(Item(name: "Item \(i)", primaryField: "A", secondaryField: "B"))
        }
        XCTAssertEqual(store.items.count, store.freeItemLimit + 5)
    }

    func testDeleteItem() {
        let item = Item(name: "Delete Me", primaryField: "A", secondaryField: "B")
        store.addItem(item)
        store.deleteItem(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = Item(name: "Old", primaryField: "A", secondaryField: "B")
        store.addItem(item)
        item.name = "New"
        store.updateItem(item)
        XCTAssertEqual(store.items.first?.name, "New")
    }

    func testSubLogRequiresPro() {
        let item = Item(name: "Item", primaryField: "A", secondaryField: "B")
        store.addItem(item)
        let addedFree = store.addSubLog(SubLogEntry(note: "note"), to: item)
        XCTAssertFalse(addedFree)
        store.isPro = true
        let addedPro = store.addSubLog(SubLogEntry(note: "note"), to: item)
        XCTAssertTrue(addedPro)
        XCTAssertEqual(store.items.first?.subLogs.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.addItem(Item(name: "Persisted", primaryField: "A", secondaryField: "B"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.name == "Persisted" }))
    }
}
