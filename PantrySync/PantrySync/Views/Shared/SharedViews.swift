import SwiftUI

struct ExpiryBadge: View {
    let daysLeft: Int?

    var body: some View {
        Group {
            if let days = daysLeft {
                if days < 0 {
                    Text("Expired")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red, in: Capsule())
                } else if days <= 3 {
                    Text("\(days)d left")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange, in: Capsule())
                } else if days <= 7 {
                    Text("\(days)d left")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow, in: Capsule())
                } else {
                    Text("\(days)d left")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2), in: Capsule())
                }
            } else {
                Text("No date")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15), in: Capsule())
            }
        }
    }
}

struct CategoryPicker: View {
    @Binding var selectedCategory: String?
    let categories: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(categories, id: \.self) { category in
                    FilterChip(title: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
