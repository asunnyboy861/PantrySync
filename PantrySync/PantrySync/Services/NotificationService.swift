import Foundation
import UserNotifications

struct NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleExpirationAlert(for item: String, expirationDate: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = "PantrySync Alert"
        content.body = "\(item) is expiring soon!"
        content.sound = .default

        let calendar = Calendar.current
        let alertDate = calendar.date(byAdding: .day, value: -1, to: expirationDate) ?? expirationDate

        let components = calendar.dateComponents([.year, .month, .day, .hour], from: alertDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "expiry-\(id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelAlert(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["expiry-\(id)"])
    }

    static func scheduleExpiringSoonAlert(for item: String, daysLeft: Int, id: String) {
        let content = UNMutableNotificationContent()
        content.title = "PantrySync"
        content.body = "\(item) expires in \(daysLeft) day\(daysLeft == 1 ? "" : "s")"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "expiring-\(id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
