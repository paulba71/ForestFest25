import SwiftUI

struct ArtistCard: View {
    let artist: Artist
    @EnvironmentObject private var favoriteManager: FavoriteManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(artist.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        Group {
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    )
                
                Button(action: {
                    favoriteManager.toggleFavorite(for: artist)
                }) {
                    Image(systemName: favoriteManager.isFavorited(artist) ? "heart.fill" : "heart")
                        .foregroundColor(favoriteManager.isFavorited(artist) ? .red : .white)
                        .font(.title2)
                        .padding(12)
                        .shadow(radius: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(artist.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                    Text(artist.stage.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.8))
                    Text(artist.performanceDay.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(artist.performanceTime) - \(artist.performanceEndTime)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.white.opacity(0.8))
                    Text(artist.duration)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    ArtistCard(artist: Artist.forestStageArtists[0])
        .background(Color(red: 0.4, green: 0.2, blue: 0.6))
        .environmentObject(FavoriteManager())
        .previewLayout(.sizeThatFits)
} 