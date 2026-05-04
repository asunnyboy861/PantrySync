import SwiftUI
import SwiftData

struct AddGroceryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = "Other"
    @State private var quantity = 1.0
    @State private var unit = "piece"
    @State private var estimatedPrice = ""

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

                Section("Price") {
                    TextField("Estimated price", text: $estimatedPrice)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Grocery Item")
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
        let item = GroceryItem(name: name, category: category, quantity: quantity, unit: unit)
        if let price = Double(estimatedPrice) {
            item.estimatedPrice = price
        }
        modelContext.insert(item)
        dismiss()
    }
}
