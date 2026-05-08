import SwiftUI
import SwiftData

@main
struct PantrySyncApp: App {
    @State private var hasCompletedOnboarding = OnboardingManager.shared.hasCompletedOnboarding

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: .onboardingCompleted,
                    object: nil,
                    queue: .main
                ) { _ in
                    hasCompletedOnboarding = true
                }
            }
        }
        .modelContainer(AppModelContainer.shared.container)
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

@MainActor
final class AppModelContainer {
    static let shared = AppModelContainer()
    let container: ModelContainer

    private init() {
        let schema = Schema([
            PantryItem.self, GroceryItem.self, Recipe.self,
            MealPlan.self, DailyNutritionLog.self
        ])

        let useCloudKit = UserDefaults.standard.bool(forKey: "useCloudKit")

        if useCloudKit {
            let cloudConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            do {
                self.container = try ModelContainer(for: schema, configurations: [cloudConfig])
            } catch {
                let localConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
                do {
                    self.container = try ModelContainer(for: schema, configurations: [localConfig])
                } catch {
                    fatalError("Failed to create model container: \(error)")
                }
            }
        } else {
            let localConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            do {
                self.container = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Failed to create model container: \(error)")
            }
        }
    }
}
