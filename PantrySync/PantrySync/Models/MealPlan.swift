import SwiftData
import Foundation

@Model
final class MealPlan {
    @Attribute(.unique) var id: UUID
    var weekStartDate: Date
    var breakfastRecipeIDs: [UUID]
    var lunchRecipeIDs: [UUID]
    var dinnerRecipeIDs: [UUID]
    var snackRecipeIDs: [UUID]
    var notes: [String]
    var createdAt: Date

    init(weekStartDate: Date) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.breakfastRecipeIDs = []
        self.lunchRecipeIDs = []
        self.dinnerRecipeIDs = []
        self.snackRecipeIDs = []
        self.notes = []
        self.createdAt = Date()
    }
}
