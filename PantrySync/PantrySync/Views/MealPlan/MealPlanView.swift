import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @Query private var recipes: [Recipe]
    @State private var viewModel = MealPlanViewModel()
    @State private var showingRecipePicker = false
    @State private var showingPaywall = false
    @State private var selectedMealType: MealPlanViewModel.MealType = .breakfast
    @State private var selectedDayIndex = 0

    private var currentPlan: MealPlan? {
        viewModel.mealPlan(for: mealPlans)
    }

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes Yet", systemImage: "book.closed")
                    } description: {
                        Text("Add recipes first to plan your meals")
                    } actions: {
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

                        ForEach(Array(viewModel.weekDates().enumerated()), id: \.offset) { index, date in
                            Section(formatDate(date)) {
                                mealRow(label: "Breakfast", icon: "sunrise.fill",
                                        recipeID: currentPlan.flatMap { index < $0.breakfastRecipeIDs.count ? $0.breakfastRecipeIDs[index] : nil },
                                        dayIndex: index, mealType: .breakfast)
                                mealRow(label: "Lunch", icon: "sun.max.fill",
                                        recipeID: currentPlan.flatMap { index < $0.lunchRecipeIDs.count ? $0.lunchRecipeIDs[index] : nil },
                                        dayIndex: index, mealType: .lunch)
                                mealRow(label: "Dinner", icon: "moon.stars.fill",
                                        recipeID: currentPlan.flatMap { index < $0.dinnerRecipeIDs.count ? $0.dinnerRecipeIDs[index] : nil },
                                        dayIndex: index, mealType: .dinner)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meal Plan")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        viewModel.selectedWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: viewModel.selectedWeekStart) ?? viewModel.selectedWeekStart
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItemGroup(placement: .principal) {
                    Text(weekRangeString)
                        .font(.subheadline.weight(.semibold))
                }
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
                        viewModel.selectedWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: viewModel.selectedWeekStart) ?? viewModel.selectedWeekStart
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .sheet(isPresented: $showingRecipePicker) {
                RecipePickerView(recipes: recipes, selectedRecipe: { recipe in
                    if let plan = currentPlan {
                        viewModel.assignRecipe(recipe.id, to: selectedMealType, dayIndex: selectedDayIndex, plan: plan, context: modelContext)
                    } else {
                        let newPlan = MealPlan(weekStartDate: viewModel.selectedWeekStart)
                        modelContext.insert(newPlan)
                        viewModel.assignRecipe(recipe.id, to: selectedMealType, dayIndex: selectedDayIndex, plan: newPlan, context: modelContext)
                    }
                })
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
                    Text("Unlock advanced meal planning features")
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

    private var weekRangeString: String {
        let dates = viewModel.weekDates()
        guard let first = dates.first, let last = dates.last else { return "" }
        return "\(first.formatted(.dateTime.month(.abbreviated).day())) - \(last.formatted(.dateTime.month(.abbreviated).day()))"
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    private func mealRow(label: String, icon: String, recipeID: UUID?, dayIndex: Int, mealType: MealPlanViewModel.MealType) -> some View {
        Button {
            if PremiumFeatureGate.shared.canUseFeature(.mealPlan) {
                selectedMealType = mealType
                selectedDayIndex = dayIndex
                showingRecipePicker = true
            } else {
                showingPaywall = true
            }
        } label: {
            HStack {
                Label(label, systemImage: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 90, alignment: .leading)
                Spacer()
                if let id = recipeID {
                    Text(viewModel.recipeName(for: id, recipes: recipes))
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                } else {
                    Text("Not planned")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct RecipePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let recipes: [Recipe]
    let selectedRecipe: (Recipe) -> Void
    @State private var searchText = ""

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredRecipes) { recipe in
                Button {
                    selectedRecipe(recipe)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text(recipe.title)
                                .font(.subheadline.weight(.medium))
                            HStack(spacing: 8) {
                                if recipe.prepTimeMinutes > 0 {
                                    Text("\(recipe.prepTimeMinutes) min")
                                }
                                Text("\(recipe.servings) servings")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if recipe.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
