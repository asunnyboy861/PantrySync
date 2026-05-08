import SwiftUI
import SwiftData

extension Notification.Name {
    static let switchToPantryTab = Notification.Name("switchToPantryTab")
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingPaywall = false

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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .overlay(alignment: .bottom) {
            if !PurchaseManager.shared.isPremium {
                premiumBanner
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToPantryTab)) { _ in
            selectedTab = 0
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
                    Text("Upgrade to Premium")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Barcode scan, meal plans, nutrition charts & more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.separator),
                alignment: .top
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PantryItem.self, GroceryItem.self, Recipe.self, MealPlan.self, DailyNutritionLog.self], inMemory: true)
}
