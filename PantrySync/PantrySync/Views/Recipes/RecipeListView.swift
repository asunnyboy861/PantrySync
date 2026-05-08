import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @State private var viewModel = RecipeViewModel()
    @State private var showingAddRecipe = false
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes", systemImage: "book.closed")
                    } description: {
                        Text("Add your favorite recipes to get started")
                    } actions: {
                        Button {
                            if PremiumFeatureGate.shared.isUnderLimit(.unlimitedRecipes, currentCount: recipes.count) {
                                showingAddRecipe = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Recipe", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            ScreenshotDataSeeder.seed(context: modelContext)
                        } label: {
                            Label("Try Sample Data", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List {
                        if !PurchaseManager.shared.isPremium {
                            premiumBanner
                        }

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
                    if !PurchaseManager.shared.isPremium {
                        Button {
                            showingPaywall = true
                        } label: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.orange)
                        }
                    }

                    Button {
                        viewModel.showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.showFavoritesOnly ? .pink : .secondary)
                    }
                    Button {
                        let currentCount = recipes.count
                        if PremiumFeatureGate.shared.isUnderLimit(.unlimitedRecipes, currentCount: currentCount) {
                            showingAddRecipe = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var premiumBanner: some View {
        Button {
            showingPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Go Premium")
                        .font(.subheadline.weight(.semibold))
                    Text("Unlock unlimited recipes & premium features")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
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
