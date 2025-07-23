//
//  Forest_FestApp.swift
//  Forest Fest
//
//  Created by Paul Barnes on 24/04/2025.
//

import SwiftUI

@main
struct Forest_FestApp: App {
    @StateObject private var favoriteManager = FavoriteManager()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favoriteManager)
                .environmentObject(notificationManager)
        }
    }
}
