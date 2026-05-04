import SwiftData
import Foundation

struct ScreenshotDataSeeder {
    @MainActor
    static func seed(context: ModelContext) {
        let items: [(String, String, String, Double, String, Date, Double, Double, Double, Double, Double)] = [
            ("Organic Milk", "Dairy", "Fridge", 1.0, "gallon", Date().addingTimeInterval(3*86400), 5.99, 150.0, 8.0, 12.0, 8.0),
            ("Chicken Breast", "Meat & Seafood", "Freezer", 2.0, "lb", Date().addingTimeInterval(5*86400), 8.99, 165.0, 31.0, 0.0, 3.6),
            ("Brown Rice", "Grains & Bread", "Pantry", 1.0, "bag", Date().addingTimeInterval(180*86400), 3.49, 370.0, 7.5, 77.0, 2.7),
            ("Baby Spinach", "Produce", "Fridge", 1.0, "bag", Date().addingTimeInterval(2*86400), 3.99, 23.0, 2.9, 3.6, 0.4),
            ("Greek Yogurt", "Dairy", "Fridge", 1.0, "cup", Date().addingTimeInterval(7*86400), 1.29, 100.0, 17.0, 6.0, 0.7),
            ("Salmon Fillet", "Meat & Seafood", "Fridge", 1.0, "lb", Date().addingTimeInterval(1*86400), 12.99, 208.0, 20.0, 0.0, 13.0),
            ("Cheddar Cheese", "Dairy", "Fridge", 1.0, "lb", Date().addingTimeInterval(14*86400), 6.49, 403.0, 25.0, 1.3, 33.0),
            ("Whole Wheat Bread", "Grains & Bread", "Counter", 1.0, "bag", Date().addingTimeInterval(4*86400), 4.29, 247.0, 13.0, 41.0, 3.4),
            ("Avocado", "Produce", "Counter", 3.0, "piece", Date().addingTimeInterval(2*86400), 1.50, 160.0, 2.0, 8.5, 14.7),
            ("Frozen Pizza", "Frozen", "Freezer", 2.0, "box", Date().addingTimeInterval(60*86400), 5.99, 266.0, 11.0, 33.0, 10.0),
            ("Olive Oil", "Condiments & Spices", "Pantry", 1.0, "bottle", Date().addingTimeInterval(365*86400), 8.99, 884.0, 0.0, 0.0, 100.0),
            ("Eggs", "Dairy", "Fridge", 1.0, "box", Date().addingTimeInterval(10*86400), 4.99, 155.0, 13.0, 1.1, 11.0)
        ]

        for item in items {
            let pantryItem = PantryItem(name: item.0, category: item.1, storageLocation: item.2, quantity: item.3, unit: item.4)
            pantryItem.expirationDate = item.5
            pantryItem.price = item.6
            pantryItem.caloriesPer100g = item.7
            pantryItem.proteinPer100g = item.8
            pantryItem.carbsPer100g = item.9
            pantryItem.fatPer100g = item.10
            context.insert(pantryItem)
        }

        let groceryItems: [(String, String, Double, String, Double)] = [
            ("Almond Milk", "Beverages", 1.0, "bottle", 4.99),
            ("Bananas", "Produce", 1.0, "bag", 1.29),
            ("Pasta Sauce", "Canned & Jarred", 2.0, "jar", 3.49),
            ("Ground Turkey", "Meat & Seafood", 1.0, "lb", 5.99),
            ("Blueberries", "Produce", 1.0, "box", 4.99),
            ("Tortilla Chips", "Snacks", 1.0, "bag", 3.99)
        ]

        for item in groceryItems {
            let groceryItem = GroceryItem(name: item.0, category: item.1, quantity: item.2, unit: item.3)
            groceryItem.estimatedPrice = item.4
            groceryItem.isChecked = item.0 == "Bananas"
            context.insert(groceryItem)
        }

        let recipe = Recipe(title: "Grilled Salmon with Spinach", servings: 4)
        recipe.prepTimeMinutes = 10
        recipe.cookTimeMinutes = 15
        recipe.ingredientNames = ["Salmon Fillet", "Baby Spinach", "Olive Oil", "Lemon", "Garlic", "Salt", "Pepper"]
        recipe.ingredientQuantities = [4.0, 4.0, 2.0, 1.0, 3.0, 1.0, 1.0]
        recipe.ingredientUnits = ["piece", "cups", "tbsp", "piece", "cloves", "tsp", "tsp"]
        recipe.instructions = [
            "Season salmon fillets with salt, pepper, and olive oil.",
            "Preheat grill to medium-high heat.",
            "Grill salmon for 4-5 minutes per side until flaky.",
            "Sauté spinach with garlic in olive oil for 3 minutes.",
            "Plate spinach and top with grilled salmon.",
            "Squeeze fresh lemon juice over the top and serve."
        ]
        recipe.tags = ["Healthy", "Quick", "Seafood", "Low Carb"]
        recipe.isFavorite = true
        recipe.caloriesPerServing = 320.0
        recipe.proteinPerServing = 34.0
        recipe.carbsPerServing = 5.0
        recipe.fatPerServing = 19.0
        context.insert(recipe)

        let recipe2 = Recipe(title: "Chicken Stir Fry", servings: 4)
        recipe2.prepTimeMinutes = 15
        recipe2.cookTimeMinutes = 10
        recipe2.ingredientNames = ["Chicken Breast", "Brown Rice", "Broccoli", "Soy Sauce", "Ginger", "Garlic"]
        recipe2.ingredientQuantities = [1.5, 2.0, 2.0, 3.0, 1.0, 2.0]
        recipe2.ingredientUnits = ["lb", "cups", "cups", "tbsp", "tbsp", "cloves"]
        recipe2.instructions = [
            "Cook brown rice according to package directions.",
            "Cut chicken into bite-sized pieces.",
            "Stir fry chicken in a hot wok until golden.",
            "Add broccoli and stir fry for 3 minutes.",
            "Add soy sauce and ginger, toss to combine.",
            "Serve over brown rice."
        ]
        recipe2.tags = ["Healthy", "Quick", "Asian"]
        recipe2.caloriesPerServing = 380.0
        recipe2.proteinPerServing = 35.0
        recipe2.carbsPerServing = 42.0
        recipe2.fatPerServing = 8.0
        context.insert(recipe2)

        let todayLog = DailyNutritionLog(date: Date())
        todayLog.totalCalories = 1450.0
        todayLog.totalProtein = 95.0
        todayLog.totalCarbs = 180.0
        todayLog.totalFat = 45.0
        todayLog.totalFiber = 22.0
        context.insert(todayLog)

        try? context.save()
    }
}
