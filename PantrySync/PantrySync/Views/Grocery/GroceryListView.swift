import SwiftUI
import SwiftData

struct GroceryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroceryItem.createdAt) private var items: [GroceryItem]
    @State private var viewModel = GroceryListViewModel()
    @State private var showingAddItem = false
    @State private var showingMoveToPantry = false

    private var uncheckedCount: Int {
        items.filter { !$0.isChecked }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Grocery Items",
                        systemImage: "cart",
                        description: Text("Add items to your shopping list")
                    )
                } else {
                    List {
                        let filtered = viewModel.filteredItems(items)
                        let grouped = Dictionary(grouping: filtered, by: \.category)

                        ForEach(grouped.keys.sorted(), id: \.self) { category in
                            Section(category) {
                                ForEach(grouped[category] ?? []) { item in
                                    GroceryItemRow(item: item) {
                                        viewModel.toggleItem(item, context: modelContext)
                                    }
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
                    if items.contains(where: { $0.isChecked }) {
                        Button {
                            viewModel.moveCheckedToPantry(items, context: modelContext)
                        } label: {
                            Image(systemName: "arrow.down.doc")
                        }
                    }
                    Button {
                        showingAddItem = true
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
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isChecked ? .green : .secondary)
                    .font(.title3)

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
        }
        .buttonStyle(.plain)
    }
}
