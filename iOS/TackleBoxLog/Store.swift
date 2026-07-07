import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [Item] = []
    @Published var isPro: Bool = false

    /// Free-tier cap on number of items. Deliberately well above seed count
    /// so a fresh install never trips the paywall immediately.
    let freeItemLimit = 8

    private let fileName = "tackleboxlog_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Item].self, from: data) else {
            items = Self.seedItems()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddItem: Bool {
        isPro || items.count < freeItemLimit
    }

    @discardableResult
    func addItem(_ item: Item) -> Bool {
        guard canAddItem else { return false }
        items.append(item)
        save()
        return true
    }

    func updateItem(_ item: Item) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        save()
    }

    /// Adding sub-log entries (Catch Log) is the Pro feature.
    @discardableResult
    func addSubLog(_ entry: SubLogEntry, to item: Item) -> Bool {
        guard isPro else { return false }
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return false }
        items[idx].subLogs.append(entry)
        save()
        return true
    }

    static func seedItems() -> [Item] {
        [
        Item(name: "Spinnerbait", primaryField: "Row 1, Slot A", secondaryField: "", notes: "Chartreuse blade, freshwater bass"),
        Item(name: "Crankbait", primaryField: "Row 1, Slot B", secondaryField: "", notes: "Deep diver, shad pattern"),
        Item(name: "Soft Plastic Worm", primaryField: "Row 2, Slot A", secondaryField: "", notes: "Texas rig, watermelon color"),
        ]
    }
}
