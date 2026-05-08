import Foundation

enum PremiumFeature: String, CaseIterable {
    case barcodeScan = "barcode_scan"
    case receiptScan = "receipt_scan"
    case mealPlan = "meal_plan"
    case nutritionCharts = "nutrition_charts"
    case unlimitedPantry = "unlimited_pantry"
    case unlimitedGrocery = "unlimited_grocery"
    case unlimitedRecipes = "unlimited_recipes"
    case iCloudSync = "icloud_sync"
    case customAlerts = "custom_alerts"

    var displayName: String {
        switch self {
        case .barcodeScan: return "Barcode Scanning"
        case .receiptScan: return "Receipt Scanning"
        case .mealPlan: return "Meal Planning"
        case .nutritionCharts: return "Nutrition Charts"
        case .unlimitedPantry: return "Unlimited Pantry Items"
        case .unlimitedGrocery: return "Unlimited Grocery Items"
        case .unlimitedRecipes: return "Unlimited Recipes"
        case .iCloudSync: return "iCloud Sync"
        case .customAlerts: return "Custom Alert Days"
        }
    }

    var freeLimit: Int? {
        switch self {
        case .unlimitedPantry: return 30
        case .unlimitedGrocery: return 15
        case .unlimitedRecipes: return 3
        default: return nil
        }
    }
}
