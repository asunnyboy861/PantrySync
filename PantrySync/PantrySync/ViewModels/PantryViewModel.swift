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

    func consumeItem(_ item: PantryItem, context: ModelContext, logs: [DailyNutritionLog]) {
        item.isConsumed = true
        item.consumedDate = Date()
        item.updatedAt = Date()
        
        updateNutritionLog(for: item, context: context, logs: logs)
        
        try? context.save()
    }
    
    private func updateNutritionLog(for item: PantryItem, context: ModelContext, logs: [DailyNutritionLog]) {
        let today = Date()
        let calendar = Calendar.current
        
        let log = logs.first { calendar.isDate($0.date, inSameDayAs: today) } ?? {
            let newLog = DailyNutritionLog(date: today)
            context.insert(newLog)
            return newLog
        }()
        
        let quantityIn100g: Double
        if item.unit == "g" || item.unit == "grams" {
            quantityIn100g = item.quantity / 100.0
        } else if item.unit == "kg" || item.unit == "kilograms" {
            quantityIn100g = item.quantity * 10.0
        } else if item.unit == "oz" || item.unit == "ounces" {
            quantityIn100g = item.quantity * 28.35 / 100.0
        } else if item.unit == "lb" || item.unit == "pounds" {
            quantityIn100g = item.quantity * 453.6 / 100.0
        } else {
            quantityIn100g = 1.0
        }
        
        log.totalCalories += item.caloriesPer100g * quantityIn100g
        log.totalProtein += item.proteinPer100g * quantityIn100g
        log.totalCarbs += item.carbsPer100g * quantityIn100g
        log.totalFat += item.fatPer100g * quantityIn100g
    }

    func deleteItem(_ item: PantryItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }
}
