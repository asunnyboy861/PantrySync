import SwiftUI
import SwiftData

struct PantryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [PantryItem]
    @Query private var logs: [DailyNutritionLog]
    @State private var viewModel = PantryViewModel()
    @State private var showingAddItem = false
    @State private var showingScanner = false
    @State private var showingReceiptScanner = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: PantryItem?

    var body: some View {
        NavigationStack {
            Group {
                if items.filter({ !$0.isConsumed }).isEmpty {
                    ContentUnavailableView {
                        Label("Empty Pantry", systemImage: "refrigerator")
                    } description: {
                        Text("Add items to start tracking your kitchen inventory")
                    } actions: {
                        Button {
                            let currentCount = items.filter { !$0.isConsumed }.count
                            if PremiumFeatureGate.shared.isUnderLimit(.unlimitedPantry, currentCount: currentCount) {
                                showingAddItem = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Item", systemImage: "plus")
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
                        let expiring = viewModel.expiringItems(items)
                        let expired = viewModel.expiredItems(items)
                        let filtered = viewModel.filteredItems(items)

                        if !expired.isEmpty {
                            Section("Expired") {
                                ForEach(expired) { item in
                                    PantryItemRow(item: item)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingItem = item
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                viewModel.deleteItem(item, context: modelContext)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                viewModel.consumeItem(item, context: modelContext, logs: logs)
                                            } label: {
                                                Label("Consumed", systemImage: "checkmark")
                                            }
                                            .tint(.green)
                                        }
                                }
                            }
                        }

                        if !expiring.isEmpty && expired.isEmpty {
                            Section("Expiring Soon") {
                                ForEach(expiring) { item in
                                    PantryItemRow(item: item)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingItem = item
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                viewModel.deleteItem(item, context: modelContext)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                viewModel.consumeItem(item, context: modelContext, logs: logs)
                                            } label: {
                                                Label("Consumed", systemImage: "checkmark")
                                            }
                                            .tint(.green)
                                        }
                                }
                            }
                        }

                        Section {
                            ForEach(filtered) { item in
                                PantryItemRow(item: item)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingItem = item
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteItem(item, context: modelContext)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            viewModel.consumeItem(item, context: modelContext, logs: logs)
                                        } label: {
                                            Label("Consumed", systemImage: "checkmark")
                                        }
                                        .tint(.green)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pantry")
            .searchable(text: $viewModel.searchText, prompt: "Search items...")
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

                    Menu {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            Text("All").tag(String?.none)
                            ForEach(FoodCategory.allCases) { cat in
                                Text(cat.rawValue).tag(String?.some(cat.rawValue))
                            }
                        }
                        Picker("Location", selection: $viewModel.selectedLocation) {
                            Text("All").tag(String?.none)
                            ForEach(StorageLocation.allCases) { loc in
                                Text(loc.rawValue).tag(String?.some(loc.rawValue))
                            }
                        }
                        Picker("Sort", selection: $viewModel.sortOption) {
                            ForEach(PantryViewModel.PantrySortOption.allCases, id: \.self) { opt in
                                Text(opt.rawValue).tag(opt)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }

                    Button {
                        if PremiumFeatureGate.shared.canUseFeature(.barcodeScan) {
                            showingScanner = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }

                    Button {
                        if PremiumFeatureGate.shared.canUseFeature(.receiptScan) {
                            showingReceiptScanner = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "doc.text.viewfinder")
                    }

                    Button {
                        let currentCount = items.filter { !$0.isConsumed }.count
                        if PremiumFeatureGate.shared.isUnderLimit(.unlimitedPantry, currentCount: currentCount) {
                            showingAddItem = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }

                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddPantryItemView()
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView()
            }
            .sheet(isPresented: $showingReceiptScanner) {
                ReceiptScannerView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $editingItem) { item in
                EditPantryItemView(item: item)
            }
        }
    }
}

struct PantryItemRow: View {
    let item: PantryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForCategory(item.category))
                .font(.title3)
                .foregroundStyle(colorForCategory(item.category))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 8) {
                    Text("\(item.quantity.formatted()) \(item.unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.storageLocation)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            ExpiryBadge(daysLeft: item.daysUntilExpiration)
        }
        .padding(.vertical, 4)
    }

    private func iconForCategory(_ category: String) -> String {
        FoodCategory(rawValue: category)?.icon ?? "square.grid.2x2.fill"
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Produce": return .green
        case "Dairy": return .blue
        case "Meat & Seafood": return .red
        case "Grains & Bread": return .orange
        case "Frozen": return .cyan
        case "Canned & Jarred": return .brown
        case "Snacks": return .yellow
        case "Beverages": return .teal
        case "Condiments & Spices": return .indigo
        case "Baking": return .pink
        case "Household": return .gray
        default: return .secondary
        }
    }
}
