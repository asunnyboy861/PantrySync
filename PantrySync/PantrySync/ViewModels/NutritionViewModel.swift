import SwiftData
import Foundation

@Observable
class NutritionViewModel {
    var selectedDate = Date()

    func log(for date: Date, logs: [DailyNutritionLog]) -> DailyNutritionLog? {
        let calendar = Calendar.current
        return logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func getOrCreateLog(for date: Date, logs: [DailyNutritionLog], context: ModelContext) -> DailyNutritionLog {
        if let existing = log(for: date, logs: logs) {
            return existing
        }
        let newLog = DailyNutritionLog(date: date)
        context.insert(newLog)
        try? context.save()
        return newLog
    }

    func addConsumption(calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double = 0,
                        to log: DailyNutritionLog, context: ModelContext) {
        log.totalCalories += calories
        log.totalProtein += protein
        log.totalCarbs += carbs
        log.totalFat += fat
        log.totalFiber += fiber
        try? context.save()
    }

    func weekLogs(logs: [DailyNutritionLog]) -> [DailyNutritionLog] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        return (0..<7).compactMap { dayOffset -> DailyNutritionLog? in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { return nil }
            return log(for: date, logs: logs)
        }
    }
}
