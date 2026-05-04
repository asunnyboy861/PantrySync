import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var servings = 4
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var ingredientName = ""
    @State private var ingredientQuantity = ""
    @State private var ingredientUnit = ""
    @State private var ingredientNames: [String] = []
    @State private var ingredientQuantities: [Double] = []
    @State private var ingredientUnits: [String] = []
    @State private var instructionText = ""
    @State private var instructions: [String] = []
    @State private var tagText = ""
    @State private var tags: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Info") {
                    TextField("Recipe title", text: $title)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                    TextField("Prep time (min)", text: $prepTime)
                        .keyboardType(.numberPad)
                    TextField("Cook time (min)", text: $cookTime)
                        .keyboardType(.numberPad)
                }

                Section("Ingredients") {
                    ForEach(Array(ingredientNames.enumerated()), id: \.offset) { index, name in
                        HStack {
                            Text(name)
                            Spacer()
                            let qty = index < ingredientQuantities.count ? ingredientQuantities[index].formatted() : ""
                            let unit = index < ingredientUnits.count ? ingredientUnits[index] : ""
                            Text("\(qty) \(unit)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                    .onDelete { offsets in
                        for i in offsets {
                            ingredientNames.remove(at: i)
                            if i < ingredientQuantities.count { ingredientQuantities.remove(at: i) }
                            if i < ingredientUnits.count { ingredientUnits.remove(at: i) }
                        }
                    }

                    HStack {
                        TextField("Name", text: $ingredientName)
                        TextField("Qty", text: $ingredientQuantity)
                            .frame(width: 50)
                            .keyboardType(.decimalPad)
                        TextField("Unit", text: $ingredientUnit)
                            .frame(width: 50)
                        Button {
                            addIngredient()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(ingredientName.isEmpty)
                    }
                }

                Section("Instructions") {
                    ForEach(Array(instructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .foregroundStyle(.secondary)
                            Text(step)
                        }
                        .font(.subheadline)
                    }
                    .onDelete { offsets in
                        offsets.forEach { instructions.remove(at: $0) }
                    }

                    HStack {
                        TextField("Add step", text: $instructionText)
                        Button {
                            if !instructionText.isEmpty {
                                instructions.append(instructionText)
                                instructionText = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(instructionText.isEmpty)
                    }
                }

                Section("Tags") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15), in: Capsule())
                            }
                        }
                    }
                    HStack {
                        TextField("Add tag", text: $tagText)
                        Button {
                            if !tagText.isEmpty && !tags.contains(tagText) {
                                tags.append(tagText)
                                tagText = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(tagText.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveRecipe() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func addIngredient() {
        ingredientNames.append(ingredientName)
        ingredientQuantities.append(Double(ingredientQuantity) ?? 1)
        ingredientUnits.append(ingredientUnit)
        ingredientName = ""
        ingredientQuantity = ""
        ingredientUnit = ""
    }

    private func saveRecipe() {
        let recipe = Recipe(title: title, servings: servings)
        recipe.prepTimeMinutes = Int(prepTime) ?? 0
        recipe.cookTimeMinutes = Int(cookTime) ?? 0
        recipe.ingredientNames = ingredientNames
        recipe.ingredientQuantities = ingredientQuantities
        recipe.ingredientUnits = ingredientUnits
        recipe.instructions = instructions
        recipe.tags = tags
        modelContext.insert(recipe)
        dismiss()
    }
}
