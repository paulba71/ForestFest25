import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var favoriteManager: FavoriteManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingTestAlert = false
    @State private var testAlertMessage = ""
    @State private var isTestSectionExpanded = false
    @State private var isDataSectionExpanded = false
    @State private var showingDeleteAlert = false
    @State private var showingImportAlert = false
    @State private var showingExportAlert = false
    
    private let reminderOptions = [15, 30, 45, 60, 90, 120] // minutes
    
    // Data Management Functions
    private func exportFavorites() {
        let favorites = favoriteManager.favoritedArtists
        let exportData = favorites.map { artist in
            [
                "id": artist.id,
                "name": artist.name,
                "stage": artist.stage.rawValue,
                "performanceDay": artist.performanceDay.rawValue,
                "performanceTime": artist.performanceTime,
                "performanceEndTime": artist.performanceEndTime
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            // In a real app, you'd save this to a file or share it
            // For now, we'll just show an alert with the data
            testAlertMessage = "Exported \(favorites.count) favorites:\n\n\(jsonString)"
            showingExportAlert = true
        } catch {
            testAlertMessage = "Failed to export favorites: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
    
    private func importFavorites() {
        // In a real app, you'd read from a file
        // For now, we'll show a placeholder message
        testAlertMessage = "Import functionality would open a file picker to select a JSON file with your favorites data."
        showingImportAlert = true
    }
    
    private func deleteAllFavorites() {
        favoriteManager.clearAllFavorites()
        testAlertMessage = "All favorites have been deleted."
        showingDeleteAlert = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty view for balance
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
                    .imageScale(.large)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            ScrollView {
                VStack(spacing: 20) {
                    // Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                            
                            Text("Notifications")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            // Enable/Disable Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Enable Notifications")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Get reminded about your favorite acts")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationManager.notificationsEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Reminder Time Picker
                            if notificationManager.notificationsEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Reminder Time")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("How many minutes before the performance?")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Picker("Reminder Time", selection: $notificationManager.reminderTime) {
                                        ForEach(reminderOptions, id: \.self) { minutes in
                                            Text("\(minutes) minutes").tag(minutes)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    
                    // Notification Types Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            Text("Notification Types")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            NotificationTypeRow(
                                icon: "music.note",
                                title: "Performance Reminders",
                                description: "Get notified before your favorite acts start",
                                color: .purple
                            )
                            
                            NotificationTypeRow(
                                icon: "exclamationmark.triangle",
                                title: "Schedule Conflicts",
                                description: "Warned about overlapping performances",
                                color: .orange
                            )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    
                    // App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("App Information")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            InfoRow(title: "App Version", value: "1.0.0")
                            InfoRow(title: "Festival", value: "Forest Fest 2025")
                            InfoRow(title: "Dates", value: "July 25-27, 2025")
                            InfoRow(title: "Location", value: "Emo Village, Co. Laois")
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    
                    // Data Management Section (Collapsible)
                    VStack(alignment: .leading, spacing: 0) {
                        // Header (always visible)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isDataSectionExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                
                                Text("Data Management")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: isDataSectionExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(16)
                        
                        // Collapsible Content
                        if isDataSectionExpanded {
                            VStack(spacing: 12) {
                                Text("Manage your favorite acts data - export, import, or delete your schedule")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                                
                                // Data Management Buttons Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    Button(action: exportFavorites) {
                                        HStack {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.caption)
                                            Text("Export Favorites")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                    }
                                    
                                    Button(action: importFavorites) {
                                        HStack {
                                            Image(systemName: "square.and.arrow.down")
                                                .font(.caption)
                                            Text("Import Favorites")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                    }
                                    
                                    Button(action: {
                                        showingDeleteAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "trash")
                                                .font(.caption)
                                            Text("Delete All")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.red)
                                        .cornerRadius(8)
                                    }
                                    
                                    Button(action: {
                                        testAlertMessage = "You have \(favoriteManager.favoritedArtists.count) favorite acts in your schedule."
                                        showingTestAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "info.circle")
                                                .font(.caption)
                                            Text("Favorites Count")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.orange)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    
                    // Test Notifications Section (Collapsible)
                    if notificationManager.notificationsEnabled {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header (always visible)
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isTestSectionExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "testtube.2")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text("Test Notifications")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isTestSectionExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(16)
                            
                            // Collapsible Content
                            if isTestSectionExpanded {
                                VStack(spacing: 12) {
                                    Text("Test the notification system to make sure it's working properly")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal)
                                    
                                    // Test Buttons Grid
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 8) {
                                        Button(action: {
                                            notificationManager.sendTestNotification(type: .performance, delay: 10, useRealData: true)
                                        }) {
                                            HStack {
                                                Image(systemName: "music.note")
                                                    .font(.caption)
                                                Text("Real Performance")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.purple)
                                            .cornerRadius(8)
                                        }
                                        
                                        Button(action: {
                                            notificationManager.sendTestNotification(type: .conflict, delay: 10, useRealData: true)
                                        }) {
                                            HStack {
                                                Image(systemName: "exclamationmark.triangle")
                                                    .font(.caption)
                                                Text("Real Conflict")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.orange)
                                            .cornerRadius(8)
                                        }
                                        
                                        Button(action: {
                                            notificationManager.sendTestNotification(type: .custom)
                                        }) {
                                            HStack {
                                                Image(systemName: "bell.badge")
                                                    .font(.caption)
                                                Text("Custom")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                        }
                                        
                                        Button(action: {
                                            notificationManager.sendImmediateTestNotification(type: .performance, useRealData: true)
                                        }) {
                                            HStack {
                                                Image(systemName: "bolt.fill")
                                                    .font(.caption)
                                                Text("Real Immediate")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.yellow)
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    // Debug Buttons
                                    VStack(spacing: 8) {
                                        Button(action: {
                                            notificationManager.checkNotificationStatus()
                                        }) {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                    .font(.caption)
                                                Text("Check Notification Status")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.gray)
                                            .cornerRadius(8)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Button(action: {
                                            notificationManager.forceRequestPermission()
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.clockwise")
                                                    .font(.caption)
                                                Text("Request Permissions Again")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.red)
                                            .cornerRadius(8)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
        .alert("Test Notification", isPresented: $showingTestAlert) {
            Button("OK") { }
        } message: {
            Text(testAlertMessage)
        }
        .alert("Export Favorites", isPresented: $showingExportAlert) {
            Button("OK") { }
        } message: {
            Text(testAlertMessage)
        }
        .alert("Import Favorites", isPresented: $showingImportAlert) {
            Button("OK") { }
        } message: {
            Text(testAlertMessage)
        }
        .alert("Delete All Favorites", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllFavorites()
            }
        } message: {
            Text("Are you sure you want to delete all your favorite acts? This action cannot be undone.")
        }
        .onAppear {
            if notificationManager.notificationsEnabled {
                notificationManager.checkNotificationStatus()
            }
        }
    }
}

struct NotificationTypeRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .environmentObject(NotificationManager())
        .environmentObject(FavoriteManager())
} 