import SwiftData
import Foundation

@Observable
class GroceryListViewModel {
    var searchText = ""
    var showChecked = false

    func filteredItems(_ items: [GroceryItem]) -> [GroceryItem] {
        var filtered = items

        if !showChecked {
            filtered = filtered.filter { !$0.isChecked }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return filtered.sorted { !$0.isChecked && $1.isChecked }
    }

    func toggleItem(_ item: GroceryItem, context: ModelContext) {
        item.isChecked.toggle()
        try? context.save()
    }

    func deleteItem(_ item: GroceryItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }

    func moveCheckedToPantry(_ items: [GroceryItem], context: ModelContext) {
        let checkedItems = items.filter { $0.isChecked }
        for groceryItem in checkedItems {
            let pantryItem = PantryItem(
                name: groceryItem.name,
                category: groceryItem.category,
                quantity: groceryItem.quantity,
                unit: groceryItem.unit
            )
            if let price = groceryItem.estimatedPrice {
                pantryItem.price = price
            }
            context.insert(pantryItem)
            context.delete(groceryItem)
        }
        try? context.save()
    }

    func clearCheckedItems(_ items: [GroceryItem], context: ModelContext) {
        let checkedItems = items.filter { $0.isChecked }
        for item in checkedItems {
            context.delete(item)
        }
        try? context.save()
    }
}
