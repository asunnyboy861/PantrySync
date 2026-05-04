import SwiftData
import Foundation

@Observable
class RecipeViewModel {
    var searchText = ""
    var selectedTag: String?
    var showFavoritesOnly = false

    func filteredRecipes(_ recipes: [Recipe]) -> [Recipe] {
        var filtered = recipes

        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredientNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }

        return filtered.sorted { $0.createdAt > $1.createdAt }
    }

    func toggleFavorite(_ recipe: Recipe, context: ModelContext) {
        recipe.isFavorite.toggle()
        try? context.save()
    }

    func deleteRecipe(_ recipe: Recipe, context: ModelContext) {
        context.delete(recipe)
        try? context.save()
    }

    func addIngredientsToGroceryList(_ recipe: Recipe, context: ModelContext) {
        for (index, name) in recipe.ingredientNames.enumerated() {
            let quantity = index < recipe.ingredientQuantities.count ? recipe.ingredientQuantities[index] : 1
            let unit = index < recipe.ingredientUnits.count ? recipe.ingredientUnits[index] : ""
            let item = GroceryItem(name: name, quantity: quantity, unit: unit)
            item.linkedRecipeName = recipe.title
            item.isManual = false
            context.insert(item)
        }
        try? context.save()
    }

    func allTags(_ recipes: [Recipe]) -> [String] {
        let tags = Set(recipes.flatMap { $0.tags })
        return tags.sorted()
    }
}
