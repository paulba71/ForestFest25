import SwiftUI

class FavoriteManager: ObservableObject {
    @Published private(set) var favoritedArtistIDs: [String] = []
    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoritedArtists"
    
    init() {
        // Load saved favorites
        if let savedFavorites = defaults.array(forKey: favoritesKey) as? [String] {
            favoritedArtistIDs = savedFavorites
        }
    }
    
    func toggleFavorite(for artist: Artist) {
        if isFavorited(artist) {
            favoritedArtistIDs.removeAll { $0 == artist.id }
        } else {
            favoritedArtistIDs.append(artist.id)
        }
        // Save changes
        defaults.set(favoritedArtistIDs, forKey: favoritesKey)
        objectWillChange.send()
        
        // Update notifications when favorites change
        NotificationCenter.default.post(name: .favoritesChanged, object: nil)
    }
    
    func isFavorited(_ artist: Artist) -> Bool {
        favoritedArtistIDs.contains(artist.id)
    }
    
    var favoritedArtists: [Artist] {
        Artist.allArtists.filter { isFavorited($0) }
    }
    
    func clearAllFavorites() {
        favoritedArtistIDs.removeAll()
        defaults.set(favoritedArtistIDs, forKey: favoritesKey)
        objectWillChange.send()
        
        // Update notifications when favorites change
        NotificationCenter.default.post(name: .favoritesChanged, object: nil)
    }
}

extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
} 