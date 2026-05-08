import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var isLoading = false

    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                featuresPage.tag(1)
                premiumPage.tag(2)
                getStartedPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "refrigerator.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)
            Text("Welcome to PantrySync Pro")
                .font(.largeTitle.bold())
            Text("Your smart kitchen companion for managing pantry, grocery lists, recipes, and nutrition.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .padding()
    }

    private var featuresPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("What You Can Do")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 16) {
                featureRow(icon: "refrigerator.fill", title: "Track Pantry", description: "Monitor expiration dates and reduce food waste")
                featureRow(icon: "cart.fill", title: "Grocery Lists", description: "Smart shopping lists synced with your pantry")
                featureRow(icon: "book.closed.fill", title: "Recipes", description: "Save and organize your favorite recipes")
                featureRow(icon: "chart.bar.fill", title: "Nutrition", description: "Track daily nutrition and meal plans")
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }

    private var premiumPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            Text("Go Premium")
                .font(.title2.bold())
            Text("Unlock barcode scanning, receipt scanning, meal planning, nutrition charts, and unlimited items.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 8) {
                premiumFeatureRow("Barcode & Receipt Scanning")
                premiumFeatureRow("Meal Planning Calendar")
                premiumFeatureRow("Nutrition Tracking & Charts")
                premiumFeatureRow("iCloud Family Sharing")
                premiumFeatureRow("Unlimited Items")
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    private var getStartedPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Let's Get Started")
                .font(.title2.bold())

            Text("Choose how you want to begin your PantrySync Pro journey.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button(action: loadSampleData) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Text(isLoading ? "Loading..." : "Load Sample Data")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                }
                .disabled(isLoading)

                Button(action: startFresh) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Start Fresh")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.primary)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }

    private func loadSampleData() {
        isLoading = true
        DispatchQueue.main.async {
            ScreenshotDataSeeder.seed(context: modelContext)
            completeOnboarding()
            isLoading = false
        }
    }

    private func startFresh() {
        completeOnboarding()
    }

    private func completeOnboarding() {
        OnboardingManager.shared.completeOnboarding()
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func premiumFeatureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
