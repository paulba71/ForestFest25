import SwiftUI

struct HomeView: View {
    private let ticketPurchaseURL = URL(string: "https://forestfest.ie/tickets")!
    private let eventMapURL = URL(string: "https://forestfest.ie/sitemap-2025/")!
    @State private var showingLineup = false
    @State private var showingMap = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Image
                    Image("forest-fest-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top)
                    
                    // Festival Title
                    Text("Forest Fest 2025")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Date and Location
                    VStack(spacing: 8) {
                        Text("July 25-27, 2025")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Emo, Ireland")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    // Description
                    Text("Join us for an unforgettable weekend of music, art, and nature in the heart of Ireland's beautiful forests.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                    // Call to Action Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            UIApplication.shared.open(ticketPurchaseURL)
                        }) {
                            Text("Get Tickets")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showingLineup = true
                        }) {
                            Text("View Lineup")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showingMap = true
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .font(.headline)
                                Text("Event Map")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Social Media Links
                    HStack(spacing: 20) {
                        Button(action: {
                            // TODO: Add social media actions
                        }) {
                            Image(systemName: "instagram")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            // TODO: Add social media actions
                        }) {
                            Image(systemName: "facebook")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            // TODO: Add social media actions
                        }) {
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(Color(red: 0.4, green: 0.2, blue: 0.6))
            .sheet(isPresented: $showingLineup) {
                LineupView()
            }
            .sheet(isPresented: $showingMap) {
                EventMapView()
            }
        }
    }
}

#Preview {
    HomeView()
} 