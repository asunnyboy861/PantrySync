import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @Query private var recipes: [Recipe]
    @State private var viewModel = MealPlanViewModel()

    private var currentPlan: MealPlan? {
        viewModel.mealPlan(for: mealPlans)
    }

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes Yet",
                        systemImage: "book.closed",
                        description: Text("Add recipes first to plan your meals")
                    )
                } else {
                    List {
                        ForEach(Array(viewModel.weekDates().enumerated()), id: \.offset) { index, date in
                            Section(formatDate(date)) {
                                mealRow(label: "Breakfast", icon: "sunrise.fill",
                                        recipeID: currentPlan.flatMap { index < $0.breakfastRecipeIDs.count ? $0.breakfastRecipeIDs[index] : nil },
                                        dayIndex: index)
                                mealRow(label: "Lunch", icon: "sun.max.fill",
                                        recipeID: currentPlan.flatMap { index < $0.lunchRecipeIDs.count ? $0.lunchRecipeIDs[index] : nil },
                                        dayIndex: index)
                                mealRow(label: "Dinner", icon: "moon.stars.fill",
                                        recipeID: currentPlan.flatMap { index < $0.dinnerRecipeIDs.count ? $0.dinnerRecipeIDs[index] : nil },
                                        dayIndex: index)
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
                    Button {
                        viewModel.selectedWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: viewModel.selectedWeekStart) ?? viewModel.selectedWeekStart
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
    }

    private var weekRangeString: String {
        let dates = viewModel.weekDates()
        guard let first = dates.first, let last = dates.last else { return "" }
        return "\(first.formatted(.dateTime.month(.abbreviated).day())) - \(last.formatted(.dateTime.month(.abbreviated).day()))"
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    private func mealRow(label: String, icon: String, recipeID: UUID?, dayIndex: Int) -> some View {
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
            } else {
                Text("Not planned")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
