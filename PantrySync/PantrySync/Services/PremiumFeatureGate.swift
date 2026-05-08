import SwiftUI
import SwiftData

@MainActor
@Observable
final class PremiumFeatureGate {
    static let shared = PremiumFeatureGate()

    private var purchaseManager: PurchaseManager { PurchaseManager.shared }

    private init() {}

    func canUseFeature(_ feature: PremiumFeature) -> Bool {
        if purchaseManager.isPremium { return true }

        switch feature {
        case .barcodeScan, .receiptScan, .mealPlan, .nutritionCharts, .iCloudSync, .customAlerts:
            return false
        case .unlimitedPantry, .unlimitedGrocery, .unlimitedRecipes:
            return true
        }
    }

    func isUnderLimit(_ feature: PremiumFeature, currentCount: Int) -> Bool {
        if purchaseManager.isPremium { return true }
        guard let limit = feature.freeLimit else { return true }
        return currentCount < limit
    }

    func limitMessage(for feature: PremiumFeature) -> String? {
        if purchaseManager.isPremium { return nil }
        guard let limit = feature.freeLimit else { return nil }
        return "Free limit: \(limit) items. Upgrade to Premium for unlimited access."
    }

    func remainingCount(for feature: PremiumFeature, currentCount: Int) -> Int? {
        if purchaseManager.isPremium { return nil }
        guard let limit = feature.freeLimit else { return nil }
        return max(0, limit - currentCount)
    }
}
