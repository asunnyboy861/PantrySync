import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @State private var viewModel = RecipeViewModel()
    @State private var showingAddRecipe = false

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "book.closed",
                        description: Text("Add your favorite recipes to get started")
                    )
                } else {
                    List {
                        let filtered = viewModel.filteredRecipes(recipes)
                        ForEach(filtered) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                RecipeRow(recipe: recipe)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteRecipe(recipe, context: modelContext)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleFavorite(recipe, context: modelContext)
                                } label: {
                                    Label(recipe.isFavorite ? "Unfavorite" : "Favorite",
                                          systemImage: recipe.isFavorite ? "heart.slash" : "heart.fill")
                                }
                                .tint(.pink)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $viewModel.searchText, prompt: "Search recipes or ingredients...")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.showFavoritesOnly ? .pink : .secondary)
                    }
                    Button {
                        showingAddRecipe = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(recipe.title)
                        .font(.subheadline.weight(.medium))
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(.pink)
                    }
                }
                HStack(spacing: 8) {
                    if recipe.prepTimeMinutes > 0 {
                        Label("\(recipe.prepTimeMinutes) min", systemImage: "clock")
                            .font(.caption2)
                    }
                    Text("\(recipe.servings) servings")
                        .font(.caption2)
                    if recipe.caloriesPerServing > 0 {
                        Text(recipe.caloriesPerServing.formattedCalories)
                            .font(.caption2)
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
