import Foundation

actor BarcodeLookupService {
    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"

    struct ProductInfo {
        let name: String
        let barcode: String
        let category: String
        let caloriesPer100g: Double
        let proteinPer100g: Double
        let carbsPer100g: Double
        let fatPer100g: Double
        let imageURL: String?
    }

    func lookup(barcode: String) async -> ProductInfo? {
        guard let url = URL(string: "\(baseURL)/\(barcode).json") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let product = json["product"] as? [String: Any],
                  let status = json["status"] as? Int,
                  status == 1 else { return nil }

            let name = product["product_name"] as? String ?? "Unknown"
            let categories = product["categories"] as? String ?? ""
            let category = mapCategory(categories)

            let nutriments = product["nutriments"] as? [String: Any] ?? [:]
            let calories = nutriments["energy-kcal_100g"] as? Double ?? 0
            let protein = nutriments["proteins_100g"] as? Double ?? 0
            let carbs = nutriments["carbohydrates_100g"] as? Double ?? 0
            let fat = nutriments["fat_100g"] as? Double ?? 0
            let imageURL = product["image_front_url"] as? String

            return ProductInfo(
                name: name,
                barcode: barcode,
                category: category,
                caloriesPer100g: calories,
                proteinPer100g: protein,
                carbsPer100g: carbs,
                fatPer100g: fat,
                imageURL: imageURL
            )
        } catch {
            return nil
        }
    }

    private func mapCategory(_ categories: String) -> String {
        let lower = categories.lowercased()
        if lower.contains("dairy") || lower.contains("milk") { return "Dairy" }
        if lower.contains("meat") || lower.contains("seafood") { return "Meat & Seafood" }
        if lower.contains("produce") || lower.contains("fruit") || lower.contains("vegetable") { return "Produce" }
        if lower.contains("beverage") || lower.contains("drink") { return "Beverages" }
        if lower.contains("snack") { return "Snacks" }
        if lower.contains("cereal") || lower.contains("grain") { return "Grains & Bread" }
        if lower.contains("frozen") { return "Frozen" }
        if lower.contains("canned") { return "Canned & Jarred" }
        if lower.contains("condiment") || lower.contains("spice") { return "Condiments & Spices" }
        if lower.contains("baking") { return "Baking" }
        return "Other"
    }
}
