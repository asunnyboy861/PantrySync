import SwiftData
import Foundation

@Model
final class PantryItem {
    var id: UUID
    var name: String
    var barcode: String?
    var category: String
    var storageLocation: String
    var quantity: Double
    var unit: String
    var purchaseDate: Date
    var expirationDate: Date?
    var price: Double?
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var imageData: Data?
    var isConsumed: Bool
    var consumedDate: Date?
    var createdAt: Date
    var updatedAt: Date

    var isExpired: Bool {
        guard let exp = expirationDate else { return false }
        return exp < Date()
    }

    var daysUntilExpiration: Int? {
        guard let exp = expirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: exp).day
    }

    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiration else { return false }
        return days >= 0 && days <= 3
    }

    init(name: String, category: String = "Other", storageLocation: String = "Pantry",
         quantity: Double = 1, unit: String = "piece") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.storageLocation = storageLocation
        self.quantity = quantity
        self.unit = unit
        self.purchaseDate = Date()
        self.caloriesPer100g = 0
        self.proteinPer100g = 0
        self.carbsPer100g = 0
        self.fatPer100g = 0
        self.isConsumed = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
