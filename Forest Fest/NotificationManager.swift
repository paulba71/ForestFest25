import Foundation
import UserNotifications

enum TestNotificationType {
    case performance
    case conflict
    case custom
}

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                requestPermission()
            } else {
                removeAllNotifications()
            }
        }
    }
    
    @Published var reminderTime: Int = 30 {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
            if notificationsEnabled {
                scheduleNotificationsForFavorites()
            }
        }
    }
    
    override init() {
        super.init()
        
        // Load values from UserDefaults
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        let savedReminderTime = UserDefaults.standard.integer(forKey: "reminderTime")
        if savedReminderTime > 0 {
            self.reminderTime = savedReminderTime
        }
        
        // Listen for favorite changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesChanged),
            name: .favoritesChanged,
            object: nil
        )
        
        // Set self as notification delegate
        UNUserNotificationCenter.current().delegate = self
    }
    
    @objc private func favoritesChanged() {
        if notificationsEnabled {
            scheduleNotificationsForFavorites()
            checkForConflicts()
        }
    }
    
    func requestPermission() {
        print("🔐 Requesting notification permissions...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permissions granted")
                    self.scheduleNotificationsForFavorites()
                } else {
                    print("❌ Notification permissions denied")
                    self.notificationsEnabled = false
                }
                if let error = error {
                    print("❌ Permission request error: \(error)")
                }
            }
        }
    }
    
    func forceRequestPermission() {
        print("🔄 Force requesting notification permissions...")
        // First check current status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    print("⚠️ Notifications are currently denied. Please enable them in iOS Settings:")
                    print("   Settings → Forest Fest → Notifications → Allow Notifications")
                }
                
                // Request again anyway
                self.requestPermission()
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("📱 Notification Settings:")
                print("   Authorization Status: \(settings.authorizationStatus.rawValue) - \(self.authorizationStatusString(settings.authorizationStatus))")
                print("   Alert Setting: \(settings.alertSetting.rawValue) - \(self.settingStatusString(settings.alertSetting))")
                print("   Badge Setting: \(settings.badgeSetting.rawValue) - \(self.settingStatusString(settings.badgeSetting))")
                print("   Sound Setting: \(settings.soundSetting.rawValue) - \(self.settingStatusString(settings.soundSetting))")
                print("   Notification Center Setting: \(settings.notificationCenterSetting.rawValue) - \(self.settingStatusString(settings.notificationCenterSetting))")
                print("   Lock Screen Setting: \(settings.lockScreenSetting.rawValue) - \(self.settingStatusString(settings.lockScreenSetting))")
                
                if settings.authorizationStatus == .denied {
                    print("❌ NOTIFICATIONS ARE DENIED - Please enable in Settings")
                } else if settings.authorizationStatus == .authorized {
                    print("✅ Notifications are authorized")
                }
            }
        }
    }
    
    private func authorizationStatusString(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    private func settingStatusString(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "Not Supported"
        case .disabled: return "Disabled"
        case .enabled: return "Enabled"
        @unknown default: return "Unknown"
        }
    }
    
    // MARK: - Test Notifications
    
    func sendTestNotification(type: TestNotificationType) {
        sendTestNotification(type: type, delay: 10)
    }
    
    func sendTestNotification(type: TestNotificationType, delay: TimeInterval) {
        sendTestNotification(type: type, delay: delay, useRealData: false)
    }
    
    func sendTestNotification(type: TestNotificationType, delay: TimeInterval, useRealData: Bool) {
        guard notificationsEnabled else { 
            print("❌ Test notification failed: notifications not enabled")
            return 
        }
        
        print("🔔 Attempting to send test notification of type: \(type)")
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        
        if useRealData {
            switch type {
            case .performance:
                if let realArtist = getRandomUpcomingArtist() {
                    content.title = "🎵 \(realArtist.name) starts soon!"
                    content.body = "Your favorite act starts in \(reminderTime) minutes on \(realArtist.stage.rawValue)"
                } else {
                    content.title = "🎵 Test Performance Reminder"
                    content.body = "This is a test notification for performance reminders. Your favorite act would start in \(reminderTime) minutes!"
                }
                
            case .conflict:
                if let conflict = getRandomConflict() {
                    content.title = "⚠️ Schedule Conflict!"
                    content.body = "\(conflict.artist1.name) and \(conflict.artist2.name) overlap on \(conflict.artist1.performanceDay.rawValue)"
                } else {
                    content.title = "⚠️ Test Schedule Conflict"
                    content.body = "This is a test notification for schedule conflicts. You have overlapping performances!"
                }
                
            case .custom:
                content.title = "🔔 Test Custom Notification"
                content.body = "This is a test notification to verify the notification system is working properly."
            }
        } else {
            switch type {
            case .performance:
                content.title = "🎵 Test Performance Reminder"
                content.body = "This is a test notification for performance reminders. Your favorite act would start in \(reminderTime) minutes!"
                
            case .conflict:
                content.title = "⚠️ Test Schedule Conflict"
                content.body = "This is a test notification for schedule conflicts. You have overlapping performances!"
                
            case .custom:
                content.title = "🔔 Test Custom Notification"
                content.body = "This is a test notification to verify the notification system is working properly."
            }
        }
        
        // Send notification after specified delay
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        print("📅 Notification scheduled for: \(Date().addingTimeInterval(delay))")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending test notification: \(error)")
            } else {
                print("✅ Test notification scheduled successfully for \(delay) seconds from now")
                
                // Check pending notifications
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("📋 Current pending notifications: \(requests.count)")
                    for request in requests {
                        if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                            print("   - \(request.identifier): \(trigger.timeInterval) seconds remaining")
                        }
                    }
                }
            }
        }
    }
    
    func sendImmediateTestNotification(type: TestNotificationType) {
        sendImmediateTestNotification(type: type, useRealData: false)
    }
    
    func sendImmediateTestNotification(type: TestNotificationType, useRealData: Bool) {
        print("⚡ Sending immediate test notification...")
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        
        if useRealData {
            switch type {
            case .performance:
                if let realArtist = getRandomUpcomingArtist() {
                    content.title = "🎵 \(realArtist.name) starts soon!"
                    content.body = "Your favorite act starts in \(reminderTime) minutes on \(realArtist.stage.rawValue)"
                } else {
                    content.title = "⚡ Immediate Test"
                    content.body = "This is an immediate test notification"
                }
                
            case .conflict:
                if let conflict = getRandomConflict() {
                    content.title = "⚠️ Schedule Conflict!"
                    content.body = "\(conflict.artist1.name) and \(conflict.artist2.name) overlap on \(conflict.artist1.performanceDay.rawValue)"
                } else {
                    content.title = "⚡ Immediate Test"
                    content.body = "This is an immediate test notification"
                }
                
            case .custom:
                content.title = "⚡ Immediate Test"
                content.body = "This is an immediate test notification"
            }
        } else {
            content.title = "⚡ Immediate Test"
            content.body = "This is an immediate test notification"
        }
        
        // Try calendar trigger instead of time interval
        let calendar = Calendar.current
        let now = Date()
        let triggerDate = calendar.date(byAdding: .second, value: 3, to: now) ?? now
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "immediate-test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        print("📅 Calendar trigger set for: \(triggerDate)")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending immediate test notification: \(error)")
            } else {
                print("✅ Immediate test notification scheduled with calendar trigger")
            }
        }
    }
    
    // MARK: - Real Data Helpers
    
    private func getRandomUpcomingArtist() -> Artist? {
        let allArtists = Artist.allArtists
        let upcomingArtists = allArtists.filter { artist in
            // Filter for artists that would be "upcoming" (not too far in the past)
            let calendar = Calendar.current
            let now = Date()
            
            // Create a date for the artist's performance
            var components = DateComponents()
            components.year = 2025
            components.month = 7
            
            switch artist.performanceDay {
            case .friday: components.day = 25
            case .saturday: components.day = 26
            case .sunday: components.day = 27
            }
            
            guard let performanceDate = calendar.date(from: components) else { return false }
            
            // Add the performance time
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            guard let performanceTime = formatter.date(from: artist.performanceTime) else { return false }
            
            let performanceComponents = calendar.dateComponents([.hour, .minute], from: performanceTime)
            guard let finalPerformanceDate = calendar.date(bySettingHour: performanceComponents.hour ?? 0, minute: performanceComponents.minute ?? 0, second: 0, of: performanceDate) else { return false }
            
            // Return artists that are in the future or within the last hour
            return finalPerformanceDate > calendar.date(byAdding: .hour, value: -1, to: now) ?? now
        }
        
        return upcomingArtists.randomElement()
    }
    
    private func getRandomConflict() -> (artist1: Artist, artist2: Artist)? {
        let allArtists = Artist.allArtists
        
        // Group by day
        let groupedByDay = Dictionary(grouping: allArtists) { $0.performanceDay }
        
        for (_, dayArtists) in groupedByDay {
            let sortedArtists = dayArtists.sorted()
            
            for i in 0..<sortedArtists.count {
                for j in (i+1)..<sortedArtists.count {
                    let artist1 = sortedArtists[i]
                    let artist2 = sortedArtists[j]
                    
                    if artist1.overlaps(with: artist2) {
                        return (artist1, artist2)
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Regular Notification Methods
    
    func scheduleNotificationsForFavorites() {
        guard notificationsEnabled else { return }
        
        // Remove existing notifications
        removeAllNotifications()
        
        // Get current favorites
        let favoriteManager = FavoriteManager()
        let favorites = favoriteManager.favoritedArtists
        
        for artist in favorites {
            scheduleNotification(for: artist)
        }
    }
    
    private func scheduleNotification(for artist: Artist) {
        let content = UNMutableNotificationContent()
        content.title = "🎵 \(artist.name) starts soon!"
        content.body = "Your favorite act starts in \(reminderTime) minutes on \(artist.stage.rawValue)"
        content.sound = .default
        
        // Calculate notification time
        guard let notificationDate = calculateNotificationDate(for: artist) else { return }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "artist-\(artist.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func calculateNotificationDate(for artist: Artist) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let performanceTime = formatter.date(from: artist.performanceTime) else { return nil }
        
        // Get the date for the performance day
        let calendar = Calendar.current
        let now = Date()
        
        // Determine the year (assuming 2025 for Forest Fest)
        var components = DateComponents()
        components.year = 2025
        components.month = 7 // July
        
        switch artist.performanceDay {
        case .friday:
            components.day = 25
        case .saturday:
            components.day = 26
        case .sunday:
            components.day = 27
        }
        
        guard let performanceDate = calendar.date(from: components) else { return nil }
        
        // Combine date and time
        let performanceComponents = calendar.dateComponents([.hour, .minute], from: performanceTime)
        guard let finalPerformanceDate = calendar.date(bySettingHour: performanceComponents.hour ?? 0, minute: performanceComponents.minute ?? 0, second: 0, of: performanceDate) else { return nil }
        
        // Subtract reminder time
        return calendar.date(byAdding: .minute, value: -reminderTime, to: finalPerformanceDate)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func checkForConflicts() {
        let favoriteManager = FavoriteManager()
        let favorites = favoriteManager.favoritedArtists
        
        // Group by day and check for overlaps
        let groupedByDay = Dictionary(grouping: favorites) { $0.performanceDay }
        
        for (day, dayFavorites) in groupedByDay {
            let sortedFavorites = dayFavorites.sorted()
            
            for i in 0..<sortedFavorites.count {
                for j in (i+1)..<sortedFavorites.count {
                    let artist1 = sortedFavorites[i]
                    let artist2 = sortedFavorites[j]
                    
                    if artist1.overlaps(with: artist2) {
                        scheduleConflictNotification(artist1: artist1, artist2: artist2)
                    }
                }
            }
        }
    }
    
    private func scheduleConflictNotification(artist1: Artist, artist2: Artist) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Schedule Conflict!"
        content.body = "\(artist1.name) and \(artist2.name) overlap on \(artist1.performanceDay.rawValue)"
        content.sound = .default
        
        // Schedule for 1 hour before the first performance
        guard let notificationDate = calculateNotificationDate(for: artist1) else { return }
        let conflictDate = Calendar.current.date(byAdding: .hour, value: -1, to: notificationDate) ?? notificationDate
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: conflictDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "conflict-\(artist1.id)-\(artist2.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 Notification will present: \(notification.request.identifier)")
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Notification did receive response: \(response.notification.request.identifier)")
        completionHandler()
    }
} 