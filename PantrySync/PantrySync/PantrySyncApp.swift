import SwiftUI
import SwiftData

@main
struct PantrySyncApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PantryItem.self, GroceryItem.self, Recipe.self, MealPlan.self, DailyNutritionLog.self])
    }
}
