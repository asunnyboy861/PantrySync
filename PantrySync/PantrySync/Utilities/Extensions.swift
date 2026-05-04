import Foundation

extension Date {
    var formattedShort: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
}

extension Double {
    var formattedCalories: String {
        String(format: "%.0f cal", self)
    }

    var formattedGrams: String {
        String(format: "%.1f g", self)
    }

    var formattedPrice: String {
        String(format: "$%.2f", self)
    }
}
