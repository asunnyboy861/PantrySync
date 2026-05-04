import SwiftData
import Foundation

@Observable
class MealPlanViewModel {
    var selectedWeekStart: Date = startOfWeek()

    private static func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return calendar.date(from: components) ?? Date()
    }

    func weekDates() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: selectedWeekStart)
        }
    }

    func mealPlan(for plans: [MealPlan]) -> MealPlan? {
        plans.first { Calendar.current.isDate($0.weekStartDate, inSameDayAs: selectedWeekStart) }
    }

    func recipeName(for id: UUID, recipes: [Recipe]) -> String {
        recipes.first { $0.id == id }?.title ?? "Unknown Recipe"
    }

    func assignRecipe(_ recipeID: UUID, to meal: MealType, dayIndex: Int, plan: MealPlan, context: ModelContext) {
        switch meal {
        case .breakfast:
            if dayIndex < plan.breakfastRecipeIDs.count {
                plan.breakfastRecipeIDs[dayIndex] = recipeID
            } else {
                plan.breakfastRecipeIDs.append(recipeID)
            }
        case .lunch:
            if dayIndex < plan.lunchRecipeIDs.count {
                plan.lunchRecipeIDs[dayIndex] = recipeID
            } else {
                plan.lunchRecipeIDs.append(recipeID)
            }
        case .dinner:
            if dayIndex < plan.dinnerRecipeIDs.count {
                plan.dinnerRecipeIDs[dayIndex] = recipeID
            } else {
                plan.dinnerRecipeIDs.append(recipeID)
            }
        case .snack:
            if dayIndex < plan.snackRecipeIDs.count {
                plan.snackRecipeIDs[dayIndex] = recipeID
            } else {
                plan.snackRecipeIDs.append(recipeID)
            }
        }
        try? context.save()
    }

    enum MealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"

        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "sun.max.fill"
            case .dinner: return "moon.stars.fill"
            case .snack: return "applelogo"
            }
        }
    }
}
