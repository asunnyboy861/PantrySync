import SwiftData
import Foundation

@Observable
class PantryViewModel {
    var searchText = ""
    var selectedCategory: String?
    var selectedLocation: String?
    var sortOption: PantrySortOption = .expirationDate

    enum PantrySortOption: String, CaseIterable {
        case name = "Name"
        case expirationDate = "Expiration"
        case category = "Category"
        case purchaseDate = "Purchase Date"
    }

    func filteredItems(_ items: [PantryItem]) -> [PantryItem] {
        var filtered = items.filter { !$0.isConsumed }

        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        if let location = selectedLocation {
            filtered = filtered.filter { $0.storageLocation == location }
        }

        switch sortOption {
        case .name:
            filtered.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .expirationDate:
            filtered.sort { ($0.expirationDate ?? .distantFuture) < ($1.expirationDate ?? .distantFuture) }
        case .category:
            filtered.sort { $0.category < $1.category }
        case .purchaseDate:
            filtered.sort { $0.purchaseDate > $1.purchaseDate }
        }

        return filtered
    }

    func expiringItems(_ items: [PantryItem]) -> [PantryItem] {
        items.filter { $0.isExpiringSoon && !$0.isConsumed }
    }

    func expiredItems(_ items: [PantryItem]) -> [PantryItem] {
        items.filter { $0.isExpired && !$0.isConsumed }
    }

    func consumeItem(_ item: PantryItem, context: ModelContext) {
        item.isConsumed = true
        item.consumedDate = Date()
        item.updatedAt = Date()
        try? context.save()
    }

    func deleteItem(_ item: PantryItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }
}
