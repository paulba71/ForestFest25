//
//  ContentView.swift
//  Forest Fest
//
//  Created by Paul Barnes on 24/04/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Banner Image
                    Image("festival-header")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(15)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                    
                    // Event Details
                    VStack(spacing: 15) {
                        Text("Forest Fest 2025")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("July 25-27, 2025")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Emo Village, Co. Laois")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        NavigationLink(destination: LineupView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 24))
                                Text("View Lineup")
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(red: 0.13, green: 0.05, blue: 0.3))
                            .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: MyScheduleView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 24))
                                Text("My Schedule")
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: TimetableView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "tablecells")
                                    .font(.system(size: 24))
                                Text("Timetable")
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: EventMapView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 24))
                                Text("Event Map")
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: WeatherView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "cloud.sun.fill")
                                    .font(.system(size: 24))
                                Text("Weather")
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 24))
                                Text("Settings")
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .background(Color(red: 0.13, green: 0.05, blue: 0.3))
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
