import SwiftUI
import SwiftData

struct EditPantryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: PantryItem
    
    @State private var name: String
    @State private var category: String
    @State private var storageLocation: String
    @State private var quantity: Double
    @State private var unit: String
    @State private var expirationDate: Date
    @State private var hasExpirationDate: Bool
    @State private var price: String
    
    init(item: PantryItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        _storageLocation = State(initialValue: item.storageLocation)
        _quantity = State(initialValue: item.quantity)
        _unit = State(initialValue: item.unit)
        _expirationDate = State(initialValue: item.expirationDate ?? Date().addingTimeInterval(7 * 86400))
        _hasExpirationDate = State(initialValue: item.expirationDate != nil)
        _price = State(initialValue: item.price != nil ? String(item.price!) : "")
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
            .navigationTitle("Edit Item")
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
        item.storageLocation = storageLocation
        item.quantity = quantity
        item.unit = unit
        
        if hasExpirationDate {
            item.expirationDate = expirationDate
            NotificationService.cancelAlert(id: item.id.uuidString)
            NotificationService.scheduleExpirationAlert(
                for: name,
                expirationDate: expirationDate,
                id: item.id.uuidString
            )
        } else {
            item.expirationDate = nil
            NotificationService.cancelAlert(id: item.id.uuidString)
        }
        
        if let priceValue = Double(price) {
            item.price = priceValue
        }
        
        item.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }
}
