import Foundation

enum FoodCategory: String, CaseIterable, Identifiable {
    case produce = "Produce"
    case dairy = "Dairy"
    case meat = "Meat & Seafood"
    case grains = "Grains & Bread"
    case frozen = "Frozen"
    case canned = "Canned & Jarred"
    case snacks = "Snacks"
    case beverages = "Beverages"
    case condiments = "Condiments & Spices"
    case baking = "Baking"
    case household = "Household"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .produce: return "leaf.fill"
        case .dairy: return "drop.fill"
        case .meat: return "flame.fill"
        case .grains: return "bread.lines.fill"
        case .frozen: return "snowflake"
        case .canned: return "archivebox.fill"
        case .snacks: return "popcorn.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .condiments: return "puzzlepiece.fill"
        case .baking: return "birthday.cake.fill"
        case .household: return "house.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

enum StorageLocation: String, CaseIterable, Identifiable {
    case fridge = "Fridge"
    case freezer = "Freezer"
    case pantry = "Pantry"
    case counter = "Counter"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fridge: return "refrigerator.fill"
        case .freezer: return "snowflake"
        case .pantry: return "cabinet.fill"
        case .counter: return "countertop"
        }
    }
}

enum QuantityUnit: String, CaseIterable, Identifiable {
    case piece = "piece"
    case lb = "lb"
    case oz = "oz"
    case kg = "kg"
    case g = "g"
    case gallon = "gallon"
    case liter = "liter"
    case ml = "ml"
    case cup = "cup"
    case bag = "bag"
    case box = "box"
    case can = "can"
    case bottle = "bottle"

    var id: String { rawValue }
}
