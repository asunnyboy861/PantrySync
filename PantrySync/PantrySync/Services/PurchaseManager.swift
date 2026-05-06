import Foundation
import StoreKit

@MainActor
@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()
    
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var error: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    var monthlyProduct: Product? {
        products.first { $0.id == "com.zzoutuo.PantrySync.monthly" }
    }
    
    var yearlyProduct: Product? {
        products.first { $0.id == "com.zzoutuo.PantrySync.yearly" }
    }
    
    var lifetimeProduct: Product? {
        products.first { $0.id == "com.zzoutuo.PantrySync.lifetime" }
    }
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            let productIDs: Set<String> = [
                "com.zzoutuo.PantrySync.monthly",
                "com.zzoutuo.PantrySync.yearly",
                "com.zzoutuo.PantrySync.lifetime"
            ]
            let storeProducts = try await Product.products(for: productIDs)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await updatePurchasedProducts()
                    await transaction.finish()
                    isLoading = false
                    return true
                case .unverified:
                    error = "Purchase verification failed"
                }
            case .userCancelled:
                error = "Purchase cancelled"
            case .pending:
                error = "Purchase pending"
            @unknown default:
                error = "Unknown purchase result"
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
    
    func restorePurchases() async {
        isLoading = true
        error = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                }
            case .unverified:
                continue
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                case .unverified:
                    continue
                }
            }
        }
    }
}
