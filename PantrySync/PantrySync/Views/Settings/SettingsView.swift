import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pantryItems: [PantryItem]
    @Query private var groceryItems: [GroceryItem]
    @Query private var recipes: [Recipe]
    @AppStorage("useCloudKit") private var useCloudKit = false
    @AppStorage("expirationAlertDays") private var expirationAlertDays = 3
    @State private var showingCloudKitRestartAlert = false
    @AppStorage("calorieGoal") private var calorieGoal = 2000.0
    @AppStorage("proteinGoal") private var proteinGoal = 150.0
    @AppStorage("carbsGoal") private var carbsGoal = 250.0
    @AppStorage("fatGoal") private var fatGoal = 65.0
    @State private var showingContactSupport = false
    @State private var showingLoadSampleData = false
    @State private var showingClearData = false
    @State private var showingPaywall = false
    @State private var isRestoring = false

    private var hasAnyData: Bool {
        !pantryItems.isEmpty || !groceryItems.isEmpty || !recipes.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if PurchaseManager.shared.isPremium {
                        HStack {
                            Label("Premium Active", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("Thank you!")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Label("Upgrade to Premium", systemImage: "crown.fill")
                                    .foregroundStyle(.orange)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text("Unlock barcode scanning, nutrition charts, meal planning, and more. Monthly ($4.99/mo), Yearly ($29.99/yr), or Lifetime ($79.99).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        Task {
                            isRestoring = true
                            await PurchaseManager.shared.restorePurchases()
                            isRestoring = false
                        }
                    } label: {
                        if isRestoring {
                            HStack {
                                Text("Restoring...")
                                Spacer()
                                ProgressView()
                            }
                        } else {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(isRestoring)
                } header: {
                    Text("Subscription")
                } footer: {
                    Text("Subscriptions auto-renew unless cancelled 24 hours before the end of the current period. Manage your subscription in Settings > Apple ID > Subscriptions.")
                }

                Section("Sync") {
                    if PremiumFeatureGate.shared.canUseFeature(.iCloudSync) {
                        Toggle("Enable iCloud Sync", isOn: $useCloudKit)
                        Text("Sync your pantry, grocery lists, and recipes across devices. Restart app to apply.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Label("Enable iCloud Sync", systemImage: "icloud")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.orange)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text("iCloud Sync is a Premium feature. Upgrade to sync across devices.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Expiration Alerts") {
                    if PremiumFeatureGate.shared.canUseFeature(.customAlerts) {
                        Stepper("Alert \(expirationAlertDays) days before", value: $expirationAlertDays, in: 1...14)
                    } else {
                        HStack {
                            Label("Alert Days", systemImage: "bell.fill")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("3 days (Free)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.orange)
                        }
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Text("Upgrade to customize alert days")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section("Nutrition Goals") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Goal", value: $calorieGoal, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("Goal", value: $proteinGoal, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("Goal", value: $carbsGoal, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("Goal", value: $fatGoal, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Data Management") {
                    if !hasAnyData {
                        Button {
                            showingLoadSampleData = true
                        } label: {
                            Label("Load Sample Data", systemImage: "square.and.arrow.down")
                        }
                        Text("Load example items to explore the app features")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if hasAnyData {
                        Button(role: .destructive) {
                            showingClearData = true
                        } label: {
                            Label("Clear All Data", systemImage: "trash")
                        }
                    }
                    Button {
                        OnboardingManager.shared.resetOnboarding()
                    } label: {
                        Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                    }
                    .foregroundStyle(.secondary)
                }

                Section("Legal") {
                    Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/privacy.html")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/terms.html")!) {
                        HStack {
                            Label("Terms of Use (EULA)", systemImage: "doc.text")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Support") {
                    Button {
                        showingContactSupport = true
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/support.html")!) {
                        HStack {
                            Label("Support Page", systemImage: "questionmark.circle")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingContactSupport) {
                ContactSupportView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .alert("Load Sample Data?", isPresented: $showingLoadSampleData) {
                Button("Cancel", role: .cancel) { }
                Button("Load") {
                    ScreenshotDataSeeder.seed(context: modelContext)
                }
            } message: {
                Text("This will add example pantry items, grocery list items, and recipes to help you explore the app.")
            }
            .alert("Clear All Data?", isPresented: $showingClearData) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your pantry items, grocery lists, and recipes. This action cannot be undone.")
            }
        }
    }

    private func clearAllData() {
        for item in pantryItems { modelContext.delete(item) }
        for item in groceryItems { modelContext.delete(item) }
        for item in recipes { modelContext.delete(item) }
        try? modelContext.save()
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 0
    @State private var isPurchasing = false

    private var purchaseManager: PurchaseManager {
        PurchaseManager.shared
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)

                    Text("PantrySync Pro Premium")
                        .font(.title.bold())

                    Text("Unlock the full power of your kitchen manager")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        premiumFeatureRow(icon: "barcode.viewfinder", title: "Barcode & Receipt Scanning")
                        premiumFeatureRow(icon: "chart.bar.fill", title: "Nutrition Tracking & Charts")
                        premiumFeatureRow(icon: "calendar", title: "Meal Planning Calendar")
                        premiumFeatureRow(icon: "icloud.fill", title: "iCloud Family Sharing")
                        premiumFeatureRow(icon: "infinity", title: "Unlimited Items")
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

                    VStack(spacing: 12) {
                        if purchaseManager.isLoading {
                            ProgressView("Loading...")
                        } else if let error = purchaseManager.error, purchaseManager.products.isEmpty {
                            VStack(spacing: 12) {
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                Button {
                                    Task {
                                        await purchaseManager.retryLoadProducts()
                                    }
                                } label: {
                                    Label("Retry", systemImage: "arrow.clockwise")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                        } else {
                            planButton(index: 0, product: purchaseManager.monthlyProduct, title: "Monthly Premium", subtitle: "1 Month", price: "$4.99")
                            planButton(index: 1, product: purchaseManager.yearlyProduct, title: "Yearly Premium", subtitle: "1 Year", price: "$29.99")
                            planButton(index: 2, product: purchaseManager.lifetimeProduct, title: "Lifetime Access", subtitle: "One-time Purchase", price: "$79.99")
                        }
                    }

                    Button {
                        Task {
                            isPurchasing = true
                            let product: Product?
                            switch selectedPlan {
                            case 0: product = purchaseManager.monthlyProduct
                            case 1: product = purchaseManager.yearlyProduct
                            case 2: product = purchaseManager.lifetimeProduct
                            default: product = nil
                            }
                            if let product = product {
                                let success = await purchaseManager.purchase(product)
                                if success {
                                    dismiss()
                                }
                            }
                            isPurchasing = false
                        }
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(selectedPlan == 2 ? "Purchase Lifetime Access" : "Start 7-Day Free Trial")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .disabled(isPurchasing || purchaseManager.products.isEmpty)

                    VStack(spacing: 8) {
                        Text("Cancel anytime. No charge during trial.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("Subscriptions auto-renew unless cancelled 24 hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/privacy.html")!) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/terms.html")!) {
                            Label("Terms of Use (EULA)", systemImage: "doc.text")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func planButton(index: Int, product: Product?, title: String, subtitle: String, price: String) -> some View {
        Button {
            selectedPlan = index
        } label: {
            HStack {
                Image(systemName: selectedPlan == index ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPlan == index ? Color.accentColor : .secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if index == 1 {
                        Text("Save 50%")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                Spacer()
                Text(product?.displayPrice ?? price)
                    .font(.headline)
            }
            .padding()
            .background(selectedPlan == index ? Color.accentColor.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func premiumFeatureRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
        }
    }
}
