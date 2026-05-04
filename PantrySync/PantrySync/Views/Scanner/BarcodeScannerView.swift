import SwiftUI
import SwiftData
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var scannedBarcode = ""
    @State private var isScanning = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isScanning {
                    cameraView
                } else {
                    manualEntryView
                }
            }
            .padding()
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var cameraView: some View {
        VStack {
            Text("Point camera at barcode")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var manualEntryView: some View {
        VStack(spacing: 16) {
            Text("Enter barcode manually or use camera")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                TextField("Barcode number", text: $scannedBarcode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Button("Look Up") {
                    lookupBarcode()
                }
                .buttonStyle(.borderedProminent)
                .disabled(scannedBarcode.isEmpty || isLoading)
            }

            if isLoading {
                ProgressView()
            }

            Divider()

            Button {
                isScanning = true
            } label: {
                Label("Use Camera", systemImage: "barcode.viewfinder")
            }
            .buttonStyle(.bordered)
        }
    }

    private func lookupBarcode() {
        guard !scannedBarcode.isEmpty else { return }
        isLoading = true
        Task {
            let service = BarcodeLookupService()
            if let product = await service.lookup(barcode: scannedBarcode) {
                let item = PantryItem(name: product.name, category: product.category)
                item.barcode = product.barcode
                item.caloriesPer100g = product.caloriesPer100g
                item.proteinPer100g = product.proteinPer100g
                item.carbsPer100g = product.carbsPer100g
                item.fatPer100g = product.fatPer100g
                await MainActor.run {
                    modelContext.insert(item)
                    dismiss()
                }
            } else {
                await MainActor.run {
                    errorMessage = "Product not found. Try adding manually."
                    isLoading = false
                }
            }
        }
    }
}
