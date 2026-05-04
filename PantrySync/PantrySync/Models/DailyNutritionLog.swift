import SwiftData
import Foundation

@Model
final class DailyNutritionLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var totalFiber: Double
    var calorieGoal: Double
    var proteinGoal: Double
    var carbsGoal: Double
    var fatGoal: Double

    var calorieProgress: Double {
        guard calorieGoal > 0 else { return 0 }
        return min(totalCalories / calorieGoal, 1.0)
    }

    init(date: Date, calorieGoal: Double = 2000, proteinGoal: Double = 150,
         carbsGoal: Double = 250, fatGoal: Double = 65) {
        self.id = UUID()
        self.date = date
        self.totalCalories = 0
        self.totalProtein = 0
        self.totalCarbs = 0
        self.totalFat = 0
        self.totalFiber = 0
        self.calorieGoal = calorieGoal
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
    }
}
