import SwiftUI

struct MyScheduleView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    @Environment(\.presentationMode) var presentationMode
    
    // Stage colors
    private let stageColors: [Artist.Stage: Color] = [
        .forest: Color.purple,
        .village: Color.orange,
        .forestFleadh: Color.blue,
        .perfectDay: Color.green,
        .ibizaRewind: Color.pink,
        .vip: Color.yellow
    ]
    
    var groupedArtists: [(Artist.PerformanceDay, [Artist])] {
        let artists = favoriteManager.favoritedArtists
        let grouped = Dictionary(grouping: artists) { $0.performanceDay }
        return grouped.sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.sorted()) }
    }
    
    // Function to check if an artist has clashes with other favorited artists
    func hasClashes(_ artist: Artist) -> Bool {
        let favoritedArtists = favoriteManager.favoritedArtists
        return favoritedArtists.contains { otherArtist in
            otherArtist.id != artist.id && 
            otherArtist.performanceDay == artist.performanceDay &&
            artist.overlaps(with: otherArtist)
        }
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
                
                Text("My Schedule")
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
            
            if favoriteManager.favoritedArtists.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("No favorites added yet!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Add some artists to your schedule by tapping the heart icon in the lineup.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Clash Summary
                let clashCount = favoriteManager.favoritedArtists.filter { hasClashes($0) }.count
                if clashCount > 0 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("\(clashCount) performance\(clashCount == 1 ? "" : "s") clash\(clashCount == 1 ? "es" : "") with other favorites")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                }
                
                // Stage Legend
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach([Artist.Stage.forest, .village, .forestFleadh, .perfectDay, .ibizaRewind, .vip], id: \.self) { stage in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(stageColors[stage] ?? .gray)
                                    .frame(width: 8, height: 8)
                                Text(stage.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.black.opacity(0.2))
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(groupedArtists, id: \.0) { day, artists in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(day.rawValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(artists) { artist in
                                    HStack(spacing: 12) {
                                        // Time column
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(artist.performanceTime)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.white)
                                            
                                            Text(artist.performanceEndTime)
                                                .font(.system(.caption, design: .monospaced))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .frame(width: 60, alignment: .leading)
                                        
                                        // Colored stage indicator
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(stageColors[artist.stage] ?? .gray)
                                            .frame(width: 4, height: 40)
                                        
                                        // Artist details
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(artist.name)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                
                                                if hasClashes(artist) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.orange)
                                                        .help("Performance clashes with another favorite")
                                                }
                                            }
                                            
                                            Text(artist.stage.rawValue)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                            
                                            Text("(\(artist.duration))")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(hasClashes(artist) ? Color.orange.opacity(0.2) : Color.white.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(hasClashes(artist) ? Color.orange.opacity(0.4) : Color.clear, lineWidth: 1)
                                            )
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
    }
} 