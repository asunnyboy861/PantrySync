import SwiftData
import Foundation

@Model
final class GroceryItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var quantity: Double
    var unit: String
    var isChecked: Bool
    var isManual: Bool
    var linkedRecipeName: String?
    var estimatedPrice: Double?
    var createdAt: Date

    init(name: String, category: String = "Other",
         quantity: Double = 1, unit: String = "piece") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.isChecked = false
        self.isManual = true
        self.createdAt = Date()
    }
}
