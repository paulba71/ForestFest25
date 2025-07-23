import SwiftUI

struct TimelineView: View {
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
        let artists = Artist.allArtists
        let grouped = Dictionary(grouping: artists) { $0.performanceDay }
        return grouped.sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.sorted()) }
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
                
                Text("Timeline")
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
            
            // Timeline Content
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(groupedArtists, id: \.0) { day, artists in
                        VStack(alignment: .leading, spacing: 12) {
                            // Day Header
                            Text(day.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Timeline for this day
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 8) {
                                    ForEach(artists) { artist in
                                        TimelineEventCard(artist: artist, isFavorited: favoriteManager.isFavorited(artist))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(width: 320, height: UIScreen.main.bounds.height - 200)
                    }
                }
                .padding(.horizontal)
                .frame(minWidth: UIScreen.main.bounds.width * CGFloat(groupedArtists.count))
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
    }
}

struct TimelineEventCard: View {
    let artist: Artist
    let isFavorited: Bool
    
    // Stage colors
    private let stageColors: [Artist.Stage: Color] = [
        .forest: Color.purple,
        .village: Color.orange,
        .forestFleadh: Color.blue,
        .perfectDay: Color.green,
        .ibizaRewind: Color.pink,
        .vip: Color.yellow
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            // Time column
            VStack(alignment: .leading, spacing: 2) {
                Text(artist.performanceTime)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(artist.performanceEndTime)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 45, alignment: .leading)
            
            // Stage indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(stageColors[artist.stage] ?? .gray)
                .frame(width: 3, height: 30)
            
            // Artist details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(artist.name)
                        .font(.caption)
                        .fontWeight(isFavorited ? .bold : .medium)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isFavorited {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                
                Text(artist.stage.rawValue)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                
                Text("(\(artist.duration))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isFavorited ? Color.red.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFavorited ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
    }
}

#Preview {
    TimelineView()
        .environmentObject(FavoriteManager())
} 