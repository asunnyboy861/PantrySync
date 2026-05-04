import SwiftUI
import SwiftData
import Charts

struct NutritionDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [DailyNutritionLog]
    @State private var viewModel = NutritionViewModel()

    private var todayLog: DailyNutritionLog? {
        viewModel.log(for: Date(), logs: logs)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let log = todayLog {
                        calorieRing(log: log)
                        macroBreakdown(log: log)
                        weeklyChart
                    } else {
                        noDataView
                    }
                }
                .padding()
            }
            .navigationTitle("Nutrition")
        }
    }

    private func calorieRing(log: DailyNutritionLog) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 16)
                Circle()
                    .trim(from: 0, to: log.calorieProgress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 4) {
                    Text("\(Int(log.totalCalories))")
                        .font(.title.bold())
                    Text("of \(Int(log.calorieGoal)) cal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 160, height: 160)
        }
        .frame(maxWidth: .infinity)
    }

    private func macroBreakdown(log: DailyNutritionLog) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Macros")
                .font(.headline)

            macroBar(label: "Protein", current: log.totalProtein, goal: log.proteinGoal, color: .blue)
            macroBar(label: "Carbs", current: log.totalCarbs, goal: log.carbsGoal, color: .orange)
            macroBar(label: "Fat", current: log.totalFat, goal: log.fatGoal, color: .yellow)
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    private func macroBar(label: String, current: Double, goal: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(Int(current))/\(Int(goal))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: goal > 0 ? current / goal : 0)
                .tint(color)
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            let weekData = viewModel.weekLogs(logs: logs)
            if !weekData.isEmpty {
                Chart(weekData) { log in
                    BarMark(
                        x: .value("Day", log.date, unit: .day),
                        y: .value("Calories", log.totalCalories)
                    )
                    .foregroundStyle(Color.green.gradient)
                    RuleMark(y: .value("Goal", weekData.first?.calorieGoal ?? 2000))
                        .foregroundStyle(Color.red.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                }
                .frame(height: 200)
                .chartYAxisLabel("Cal")
            }
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    private var noDataView: some View {
        ContentUnavailableView(
            "No Nutrition Data",
            systemImage: "chart.bar",
            description: Text("Log your meals to track nutrition")
        )
    }
}
