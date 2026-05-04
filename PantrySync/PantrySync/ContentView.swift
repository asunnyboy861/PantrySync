import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PantryView()
                .tabItem {
                    Label("Pantry", systemImage: "refrigerator.fill")
                }
                .tag(0)

            GroceryListView()
                .tabItem {
                    Label("Grocery", systemImage: "cart.fill")
                }
                .tag(1)

            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.closed.fill")
                }
                .tag(2)

            MealPlanView()
                .tabItem {
                    Label("Meal Plan", systemImage: "calendar")
                }
                .tag(3)

            NutritionDashboardView()
                .tabItem {
                    Label("Nutrition", systemImage: "chart.bar.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PantryItem.self, GroceryItem.self, Recipe.self, MealPlan.self, DailyNutritionLog.self], inMemory: true)
}
