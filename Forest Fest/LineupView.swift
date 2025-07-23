import SwiftUI

struct LineupView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    @State private var selectedStage: Artist.Stage = .forest
    @State private var selectedDay: Artist.PerformanceDay? = nil
    @State private var showFavoritesOnly = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Favorites Toggle
            Toggle(isOn: $showFavoritesOnly) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("Show Favorites Only")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            // Day Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { selectedDay = nil }) {
                        Text("All Days")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedDay == nil ? Color.white : Color.white.opacity(0.2))
                            .foregroundColor(selectedDay == nil ? .purple : .white)
                            .cornerRadius(20)
                    }
                    
                    ForEach([Artist.PerformanceDay.friday, .saturday, .sunday], id: \.self) { day in
                        Button(action: { selectedDay = day }) {
                            Text(day.rawValue.components(separatedBy: ",")[0])
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedDay == day ? Color.white : Color.white.opacity(0.2))
                                .foregroundColor(selectedDay == day ? .purple : .white)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.2))
            
            // Stage Filter
            Picker("Stage", selection: $selectedStage) {
                Text("Forest Stage").tag(Artist.Stage.forest)
                Text("Village Stage").tag(Artist.Stage.village)
                Text("Forest Fleadh Stage").tag(Artist.Stage.forestFleadh)
                Text("Perfect Day Stage").tag(Artist.Stage.perfectDay)
                Text("Ibiza Rewind Tent").tag(Artist.Stage.ibizaRewind)
                Text("VIP Stage").tag(Artist.Stage.vip)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color.black.opacity(0.2))
            
            // Artists Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(sortedAndFilteredArtists) { artist in
                        ArtistCard(artist: artist)
                    }
                }
                .padding()
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
    }
    
    private var sortedAndFilteredArtists: [Artist] {
        let allArtists = Artist.allArtists
        
        // First apply favorites filter if enabled
        let favoritesFiltered = showFavoritesOnly ? allArtists.filter { favoriteManager.isFavorited($0) } : allArtists
        
        // Then filter by stage
        let stageFiltered = favoritesFiltered.filter { $0.stage == selectedStage }
        
        // Then filter by day if selected
        let dayFiltered = selectedDay.map { day in
            stageFiltered.filter { $0.performanceDay == day }
        } ?? stageFiltered
        
        // Sort by day and time using the Artist's Comparable implementation
        return dayFiltered.sorted()
    }
}

#Preview {
    LineupView()
        .environmentObject(FavoriteManager())
} 