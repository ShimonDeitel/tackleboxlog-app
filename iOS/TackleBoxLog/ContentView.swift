import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Item?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            ItemRow(item: item)
                        }
                        .listRowBackground(Theme.card)
                        .accessibilityIdentifier("itemRow_\(item.name)")
                    }
                    .onDelete { offsets in
                        store.deleteItem(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Tackle Box Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddItem {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addItemButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditItemView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                AddEditItemView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

struct ItemRow: View {
    let item: Item
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Lure Type: \(item.primaryField)")
                .font(Theme.captionFont)
                .foregroundColor(Theme.textMuted)
            if !item.secondaryField.isEmpty {
                Text("Compartment: \(item.secondaryField)")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textMuted)
            }
            if !item.subLogs.isEmpty {
                Text("\(item.subLogs.count) Catch Log entries")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}

enum EditMode: Equatable {
    case add
    case edit(Item)
}

struct AddEditItemView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    let mode: EditMode

    @State private var name: String = ""
    @State private var primaryField: String = ""
    @State private var secondaryField: String = ""
    @State private var notes: String = ""
    @State private var newSubLogNote: String = ""
    @State private var newSubLogValue: String = ""
    @State private var subLogs: [SubLogEntry] = []
    @State private var showingPaywall = false

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("nameField")
                    TextField("Lure Type", text: $primaryField)
                        .accessibilityIdentifier("primaryFieldInput")
                    TextField("Compartment", text: $secondaryField)
                        .accessibilityIdentifier("secondaryFieldInput")
                    TextField("Notes", text: $notes, axis: .vertical)
                        .accessibilityIdentifier("notesField")
                }

                Section("Catch Log") {
                    if purchases.isPurchased {
                        ForEach(subLogs) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.note).font(Theme.bodyFont)
                                if !entry.value.isEmpty {
                                    Text(entry.value).font(Theme.captionFont).foregroundColor(Theme.textMuted)
                                }
                            }
                        }
                        TextField("New catch note", text: $newSubLogNote)
                            .accessibilityIdentifier("subLogNoteField")
                        TextField("Value (optional)", text: $newSubLogValue)
                            .accessibilityIdentifier("subLogValueField")
                        Button("Add Catch Log Entry") {
                            guard !newSubLogNote.isEmpty else { return }
                            subLogs.append(SubLogEntry(note: newSubLogNote, value: newSubLogValue))
                            newSubLogNote = ""
                            newSubLogValue = ""
                        }
                        .accessibilityIdentifier("addSubLogButton")
                    } else {
                        Button("Unlock Catch Log with Pro") {
                            showingPaywall = true
                        }
                        .accessibilityIdentifier("unlockSubLogButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .accessibilityIdentifier("saveButton")
                        .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        if case .edit(let item) = mode {
            name = item.name
            primaryField = item.primaryField
            secondaryField = item.secondaryField
            notes = item.notes
            subLogs = item.subLogs
        }
    }

    private func save() {
        switch mode {
        case .add:
            let item = Item(name: name, primaryField: primaryField, secondaryField: secondaryField, notes: notes, subLogs: subLogs)
            store.addItem(item)
        case .edit(var item):
            item.name = name
            item.primaryField = primaryField
            item.secondaryField = secondaryField
            item.notes = notes
            item.subLogs = subLogs
            store.updateItem(item)
        }
        dismiss()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
