import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let recipe: Recipe
    @State private var viewModel = RecipeViewModel()
    @State private var showingEditRecipe = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                ingredientsSection
                instructionsSection
                nutritionSection
            }
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingEditRecipe = true
                } label: {
                    Image(systemName: "pencil")
                }
                Button {
                    viewModel.addIngredientsToGroceryList(recipe, context: modelContext)
                } label: {
                    Image(systemName: "cart.badge.plus")
                }
                Button {
                    viewModel.toggleFavorite(recipe, context: modelContext)
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(recipe.isFavorite ? .pink : .secondary)
                }
            }
        }
        .sheet(isPresented: $showingEditRecipe) {
            EditRecipeView(recipe: recipe)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if recipe.prepTimeMinutes > 0 {
                    Label("\(recipe.prepTimeMinutes) min prep", systemImage: "clock")
                        .font(.subheadline)
                }
                if recipe.cookTimeMinutes > 0 {
                    Label("\(recipe.cookTimeMinutes) min cook", systemImage: "flame")
                        .font(.subheadline)
                }
                Label("\(recipe.servings) servings", systemImage: "person.2")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)

            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                        }
                    }
                }
            }
        }
    }

    private var ingredientsSection: some View {
        Group {
            if !recipe.ingredientNames.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)
                    ForEach(Array(recipe.ingredientNames.enumerated()), id: \.offset) { index, name in
                        HStack {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(name)
                            Spacer()
                            let qty = index < recipe.ingredientQuantities.count ? recipe.ingredientQuantities[index] : 1
                            let unit = index < recipe.ingredientUnits.count ? recipe.ingredientUnits[index] : ""
                            Text("\(qty.formatted()) \(unit)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
    }

    private var instructionsSection: some View {
        Group {
            if !recipe.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.headline)
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.accentColor, in: Circle())
                            Text(step)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }

    private var nutritionSection: some View {
        Group {
            if recipe.caloriesPerServing > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nutrition per Serving")
                        .font(.headline)
                    HStack(spacing: 16) {
                        NutritionStat(value: recipe.caloriesPerServing, unit: "cal", label: "Calories", color: .red)
                        NutritionStat(value: recipe.proteinPerServing, unit: "g", label: "Protein", color: .blue)
                        NutritionStat(value: recipe.carbsPerServing, unit: "g", label: "Carbs", color: .orange)
                        NutritionStat(value: recipe.fatPerServing, unit: "g", label: "Fat", color: .yellow)
                    }
                }
            }
        }
    }
}

struct NutritionStat: View {
    let value: Double
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(value))")
                .font(.title3.bold())
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}
