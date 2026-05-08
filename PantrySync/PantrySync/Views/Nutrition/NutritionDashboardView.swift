import SwiftUI
import SwiftData
import Charts

struct NutritionDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [DailyNutritionLog]
    @State private var viewModel = NutritionViewModel()
    @State private var showingPaywall = false

    private var todayLog: DailyNutritionLog? {
        viewModel.log(for: Date(), logs: logs)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !PurchaseManager.shared.isPremium {
                        premiumBanner
                    }

                    if let log = todayLog {
                        calorieRing(log: log)
                        macroBreakdown(log: log)
                        if PremiumFeatureGate.shared.canUseFeature(.nutritionCharts) {
                            weeklyChart
                        } else {
                            lockedWeeklyChart
                        }
                    } else {
                        noDataView
                    }
                }
                .padding()
            }
            .navigationTitle("Nutrition")
            .toolbar {
                if !PurchaseManager.shared.isPremium {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingPaywall = true
                        } label: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var premiumBanner: some View {
        Button {
            showingPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Go Premium")
                        .font(.subheadline.weight(.semibold))
                    Text("Unlock full nutrition tracking & charts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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
        ContentUnavailableView {
            Label("No Nutrition Data", systemImage: "chart.bar")
        } description: {
            Text("Consume pantry items to automatically track your daily nutrition.")
        } actions: {
            Button {
                NotificationCenter.default.post(name: .switchToPantryTab, object: nil)
            } label: {
                Label("Go to Pantry", systemImage: "refrigerator.fill")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var lockedWeeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            Button {
                showingPaywall = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Charts Locked")
                            .font(.subheadline.weight(.semibold))
                        Text("Upgrade to Premium to view weekly nutrition charts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
