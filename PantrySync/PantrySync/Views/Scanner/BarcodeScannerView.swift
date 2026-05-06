import SwiftUI
import SwiftData
import AVFoundation
import Vision
import AudioToolbox
import Combine

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var scannedBarcode = ""
    @State private var isScanning = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showCamera = false
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if showCamera {
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
            .onAppear {
                cameraManager.requestCameraPermission()
            }
        }
    }

    private var cameraView: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text("Point camera at barcode")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.bottom, 40)
            }

            if isLoading {
                ProgressView("Looking up product...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            cameraManager.startScanning { barcode in
                Task { @MainActor in
                    isLoading = true
                    scannedBarcode = barcode
                    await lookupBarcode(barcode)
                    isLoading = false
                }
            }
        }
        .onDisappear {
            cameraManager.stopScanning()
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
                if cameraManager.isAuthorized {
                    showCamera = true
                } else {
                    errorMessage = "Camera access denied. Please enable camera access in Settings."
                }
            } label: {
                Label("Use Camera", systemImage: "barcode.viewfinder")
            }
            .buttonStyle(.bordered)
        }
    }

    private func lookupBarcode() {
        guard !scannedBarcode.isEmpty else { return }
        Task {
            isLoading = true
            await lookupBarcode(scannedBarcode)
            isLoading = false
        }
    }

    private func lookupBarcode(_ barcode: String) async {
        let service = BarcodeLookupService()
        if let product = await service.lookup(barcode: barcode) {
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
            }
        }
    }
}

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var session = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    private let metadataOutput = AVCaptureMetadataOutput()
    private var onBarcodeDetected: ((String) -> Void)?

    override init() {
        super.init()
    }

    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                }
            }
        default:
            isAuthorized = false
        }
    }

    func startScanning(onBarcodeDetected: @escaping (String) -> Void) {
        self.onBarcodeDetected = onBarcodeDetected

        guard isAuthorized else { return }

        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .code128, .qr]
        }

        session.commitConfiguration()
        session.startRunning()
    }

    func stopScanning() {
        session.stopRunning()
    }
}

extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first,
              let readableObject = object as? AVMetadataMachineReadableCodeObject,
              let barcode = readableObject.stringValue else { return }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        onBarcodeDetected?(barcode)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}
