import SwiftData
import Foundation

@Model
final class Recipe {
    var id: UUID
    var title: String
    var source: String?
    var sourceURL: String?
    var servings: Int
    var prepTimeMinutes: Int
    var cookTimeMinutes: Int
    var instructions: [String]
    var ingredientNames: [String]
    var ingredientQuantities: [Double]
    var ingredientUnits: [String]
    var imageData: Data?
    var tags: [String]
    var isFavorite: Bool
    var caloriesPerServing: Double
    var proteinPerServing: Double
    var carbsPerServing: Double
    var fatPerServing: Double
    var createdAt: Date

    init(title: String, servings: Int = 4) {
        self.id = UUID()
        self.title = title
        self.servings = servings
        self.prepTimeMinutes = 0
        self.cookTimeMinutes = 0
        self.instructions = []
        self.ingredientNames = []
        self.ingredientQuantities = []
        self.ingredientUnits = []
        self.tags = []
        self.isFavorite = false
        self.caloriesPerServing = 0
        self.proteinPerServing = 0
        self.carbsPerServing = 0
        self.fatPerServing = 0
        self.createdAt = Date()
    }
}
