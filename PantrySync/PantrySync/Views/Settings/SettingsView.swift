import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pantryItems: [PantryItem]
    @Query private var groceryItems: [GroceryItem]
    @Query private var recipes: [Recipe]
    @AppStorage("useCloudKit") private var useCloudKit = false
    @AppStorage("expirationAlertDays") private var expirationAlertDays = 3
    @AppStorage("calorieGoal") private var calorieGoal = 2000.0
    @AppStorage("proteinGoal") private var proteinGoal = 150.0
    @AppStorage("carbsGoal") private var carbsGoal = 250.0
    @AppStorage("fatGoal") private var fatGoal = 65.0
    @State private var showingContactSupport = false
    @State private var showingLoadSampleData = false
    @State private var showingClearData = false

    private var hasAnyData: Bool {
        !pantryItems.isEmpty || !groceryItems.isEmpty || !recipes.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sync") {
                    Toggle("Enable iCloud Sync", isOn: $useCloudKit)
                    Text("Sync your pantry, grocery lists, and recipes across devices")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Expiration Alerts") {
                    Stepper("Alert \(expirationAlertDays) days before", value: $expirationAlertDays, in: 1...14)
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
                }

                Section("Subscription") {
                    NavigationLink {
                        PaywallView()
                    } label: {
                        HStack {
                            Label("Upgrade to Premium", systemImage: "crown.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button("Restore Purchases") {
                    }
                }

                Section("Support") {
                    Button {
                        showingContactSupport = true
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/support.html")!) {
                        Label("Support Page", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/PantrySync/terms.html")!) {
                        Label("Terms of Use", systemImage: "doc.text")
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)

                    Text("PantrySync Premium")
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

                    Picker("Plan", selection: $selectedPlan) {
                        Text("Monthly $4.99").tag(0)
                        Text("Yearly $29.99").tag(1)
                        Text("Lifetime $79.99").tag(2)
                    }
                    .pickerStyle(.segmented)

                    Button {
                    } label: {
                        Text(selectedPlan == 2 ? "Purchase Lifetime" : "Start 7-Day Free Trial")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    }

                    Text("Cancel anytime. No charge during trial.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
