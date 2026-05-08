import SwiftUI
import SwiftData

struct GroceryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroceryItem.createdAt) private var items: [GroceryItem]
    @State private var viewModel = GroceryListViewModel()
    @State private var showingAddItem = false
    @State private var showingMoveToPantry = false
    @State private var showingPaywall = false
    @State private var editingItem: GroceryItem?

    private var uncheckedCount: Int {
        items.filter { !$0.isChecked }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView {
                        Label("No Grocery Items", systemImage: "cart")
                    } description: {
                        Text("Add items to your shopping list")
                    } actions: {
                        Button {
                            if PremiumFeatureGate.shared.isUnderLimit(.unlimitedGrocery, currentCount: items.count) {
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
                        if !PurchaseManager.shared.isPremium {
                            premiumBanner
                        }

                        let filtered = viewModel.filteredItems(items)
                        let grouped = Dictionary(grouping: filtered, by: \.category)

                        ForEach(grouped.keys.sorted(), id: \.self) { category in
                            Section(category) {
                                ForEach(grouped[category] ?? []) { item in
                                    GroceryItemRow(item: item, onToggle: {
                                        viewModel.toggleItem(item, context: modelContext)
                                    }, onEdit: {
                                        editingItem = item
                                    })
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteItem(item, context: modelContext)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Grocery List")
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

                    if items.contains(where: { $0.isChecked }) {
                        Button {
                            viewModel.moveCheckedToPantry(items, context: modelContext)
                        } label: {
                            Image(systemName: "arrow.down.doc")
                        }
                    }
                    Button {
                        let currentCount = items.count
                        if PremiumFeatureGate.shared.isUnderLimit(.unlimitedGrocery, currentCount: currentCount) {
                            showingAddItem = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("\(uncheckedCount) items remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Toggle("Show checked", isOn: $viewModel.showChecked)
                        .font(.caption)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddGroceryItemView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(item: $editingItem) { item in
                EditGroceryItemView(item: item)
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
                    Text("Unlock unlimited grocery lists & more")
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

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isChecked ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                    .strikethrough(item.isChecked)
                if item.quantity != 1 || item.unit != "piece" {
                    Text("\(item.quantity.formatted()) \(item.unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let recipe = item.linkedRecipeName {
                    Text("From: \(recipe)")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            if let price = item.estimatedPrice {
                Text(price.formattedPrice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}
