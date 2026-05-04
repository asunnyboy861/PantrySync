import SwiftUI
import SwiftData
import PhotosUI

struct ReceiptScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var receiptImage: UIImage?
    @State private var scannedItems: [ReceiptScanner.ScannedItem] = []
    @State private var isScanning = false
    @State private var selectedItems = Set<UUID>()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if scannedItems.isEmpty {
                    photoPickerSection
                } else {
                    scannedItemsList
                }
            }
            .padding()
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if !scannedItems.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add Selected") {
                            addSelectedItems()
                        }
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    receiptImage = image
                    scanReceipt(image)
                }
            }
        }
    }

    private var photoPickerSection: some View {
        VStack(spacing: 20) {
            if isScanning {
                ProgressView("Scanning receipt...")
            } else {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Take a photo of your receipt to automatically add items to your pantry")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Select Receipt Photo", systemImage: "photo.on.rectangle")
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scannedItemsList: some View {
        List {
            Section("Found \(scannedItems.count) items") {
                ForEach(scannedItems) { item in
                    HStack {
                        Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedItems.contains(item.id) ? .green : .secondary)
                            .onTapGesture {
                                if selectedItems.contains(item.id) {
                                    selectedItems.remove(item.id)
                                } else {
                                    selectedItems.insert(item.id)
                                }
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline.weight(.medium))
                            HStack(spacing: 8) {
                                Text("Qty: \(item.quantity.formatted())")
                                Text(item.category)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let price = item.price {
                            Text(price.formattedPrice)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Button("Select All") {
                selectedItems = Set(scannedItems.map { $0.id })
            }
        }
    }

    private func scanReceipt(_ image: UIImage) {
        isScanning = true
        ReceiptScanner.scanReceipt(image: image) { items in
            DispatchQueue.main.async {
                scannedItems = items
                selectedItems = Set(items.map { $0.id })
                isScanning = false
            }
        }
    }

    private func addSelectedItems() {
        for scannedItem in scannedItems where selectedItems.contains(scannedItem.id) {
            let item = PantryItem(
                name: scannedItem.name,
                category: scannedItem.category,
                quantity: scannedItem.quantity
            )
            item.price = scannedItem.price
            modelContext.insert(item)
        }
        dismiss()
    }
}
