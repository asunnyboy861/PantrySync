import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Account", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Topic") {
                    Picker("Topic", selection: $topic) {
                        ForEach(topics, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                }

                Section("Contact Info") {
                    TextField("Name (optional)", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitFeedback()
                    }
                    .disabled(email.isEmpty || message.isEmpty || isSubmitting)
                }
            }
            .overlay {
                if isSubmitting {
                    ProgressView()
                }
            }
            .alert("Feedback", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        let payload: [String: Any] = [
            "topic": topic,
            "name": name,
            "email": email,
            "message": message,
            "app": "PantrySync"
        ]

        guard let url = URL(string: "https://formsubmit.co/ajax/iocompile67692@gmail.com") else {
            alertMessage = "Failed to submit. Please try again."
            showAlert = true
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertMessage = "Message sent successfully! We will get back to you soon."
                } else {
                    alertMessage = "Failed to submit. Please try again."
                }
                showAlert = true
            }
        }.resume()
    }
}
