import SwiftUI
import SwiftData

@main
struct PantrySyncApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PantryItem.self, GroceryItem.self, Recipe.self,
            MealPlan.self, DailyNutritionLog.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
