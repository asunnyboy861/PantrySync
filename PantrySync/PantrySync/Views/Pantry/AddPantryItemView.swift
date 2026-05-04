import SwiftUI
import SwiftData

struct AddPantryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = "Other"
    @State private var storageLocation = "Pantry"
    @State private var quantity = 1.0
    @State private var unit = "piece"
    @State private var expirationDate = Date().addingTimeInterval(7 * 86400)
    @State private var hasExpirationDate = true
    @State private var price = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(FoodCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat.rawValue)
                        }
                    }
                    Picker("Location", selection: $storageLocation) {
                        ForEach(StorageLocation.allCases) { loc in
                            Text(loc.rawValue).tag(loc.rawValue)
                        }
                    }
                }

                Section("Quantity") {
                    HStack {
                        TextField("Amount", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $unit) {
                            ForEach(QuantityUnit.allCases) { u in
                                Text(u.rawValue).tag(u.rawValue)
                            }
                        }
                    }
                }

                Section("Details") {
                    Toggle("Has expiration date", isOn: $hasExpirationDate)
                    if hasExpirationDate {
                        DatePicker("Expires", selection: $expirationDate, displayedComponents: .date)
                    }
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addItem() {
        let item = PantryItem(name: name, category: category, storageLocation: storageLocation, quantity: quantity, unit: unit)
        if hasExpirationDate {
            item.expirationDate = expirationDate
        }
        if let priceValue = Double(price) {
            item.price = priceValue
        }
        modelContext.insert(item)
        if hasExpirationDate {
            NotificationService.scheduleExpirationAlert(for: name, expirationDate: expirationDate, id: item.id.uuidString)
        }
        dismiss()
    }
}
