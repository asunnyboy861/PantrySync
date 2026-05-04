import Vision
import UIKit

struct ReceiptScanner {

    struct ScannedItem: Identifiable {
        let id = UUID()
        let name: String
        let quantity: Double
        let price: Double?
        let category: String
    }

    static func scanReceipt(image: UIImage, completion: @escaping ([ScannedItem]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }

            let recognizedLines = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let items = parseReceiptLines(recognizedLines)
            completion(items)
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private static func parseReceiptLines(_ lines: [String]) -> [ScannedItem] {
        var items: [ScannedItem] = []
        let pricePattern = #"(\d+\.\d{2})$"#
        let quantityPattern = #"^(\d+)\s*[xX@]\s*"#

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let skipKeywords = ["total", "subtotal", "tax", "change", "cash", "card", "visa",
                               "mastercard", "amex", "debit", "credit", "receipt", "thank", "store"]
            if skipKeywords.contains(where: { trimmed.lowercased().contains($0) }) { continue }

            var name = trimmed
            var price: Double? = nil
            var quantity: Double = 1

            if let range = trimmed.range(of: pricePattern, options: .regularExpression) {
                let priceStr = String(trimmed[range])
                price = Double(priceStr)
                name = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }

            if let range = name.range(of: quantityPattern, options: .regularExpression) {
                let qtyStr = String(name[range]).replacingOccurrences(of: "x", with: "")
                    .replacingOccurrences(of: "X", with: "")
                    .replacingOccurrences(of: "@", with: "")
                    .trimmingCharacters(in: .whitespaces)
                if let qty = Double(qtyStr) {
                    quantity = qty
                    name = String(name[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                }
            }

            guard !name.isEmpty && name.count > 1 else { continue }

            let category = categorizeItem(name: name)
            items.append(ScannedItem(name: name, quantity: quantity, price: price, category: category))
        }

        return items
    }

    private static func categorizeItem(name: String) -> String {
        let lower = name.lowercased()
        let categoryKeywords: [String: [String]] = [
            "Produce": ["apple", "banana", "tomato", "onion", "potato", "lettuce", "carrot", "pepper", "orange", "lemon", "fruit", "vegetable", "avocado", "broccoli", "spinach", "berry", "grape", "mango"],
            "Dairy": ["milk", "cheese", "yogurt", "butter", "cream", "egg", "cottage"],
            "Meat & Seafood": ["chicken", "beef", "pork", "fish", "salmon", "shrimp", "turkey", "bacon", "sausage", "steak", "ham", "tuna"],
            "Grains & Bread": ["bread", "rice", "pasta", "cereal", "oat", "flour", "tortilla", "cracker", "noodle"],
            "Frozen": ["frozen", "ice cream", "pizza", "fries"],
            "Canned & Jarred": ["canned", "soup", "bean", "sauce", "jar", "pickle", "olive oil", "tomato sauce"],
            "Snacks": ["chip", "cookie", "candy", "nut", "popcorn", "pretzel", "granola", "bar"],
            "Beverages": ["water", "juice", "soda", "coffee", "tea", "beer", "wine", "drink", "kombucha"],
            "Condiments & Spices": ["salt", "pepper", "spice", "herb", "ketchup", "mustard", "mayo", "vinegar", "honey", "sugar"],
            "Baking": ["baking", "vanilla", "cocoa", "yeast", "baking powder", "baking soda"],
            "Household": ["paper", "soap", "detergent", "clean", "tissue", "foil", "wrap"]
        ]

        for (category, keywords) in categoryKeywords {
            if keywords.contains(where: { lower.contains($0) }) {
                return category
            }
        }
        return "Other"
    }
}
