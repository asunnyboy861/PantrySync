import SwiftUI
import SwiftData

struct EditGroceryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: GroceryItem
    
    @State private var name: String
    @State private var category: String
    @State private var quantity: Double
    @State private var unit: String
    @State private var estimatedPrice: String
    
    init(item: GroceryItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        _quantity = State(initialValue: item.quantity)
        _unit = State(initialValue: item.unit)
        _estimatedPrice = State(initialValue: item.estimatedPrice != nil ? String(item.estimatedPrice!) : "")
    }
    
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
            .navigationTitle("Edit Grocery Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        item.name = name
        item.category = category
        item.quantity = quantity
        item.unit = unit
        
        if let price = Double(estimatedPrice) {
            item.estimatedPrice = price
        }
        
        try? modelContext.save()
        dismiss()
    }
}
