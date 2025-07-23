import SwiftUI

struct TimetableView: View {
    @EnvironmentObject var favoriteManager: FavoriteManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDay: Artist.PerformanceDay = .friday
    @State private var scrollPosition: CGPoint = .zero
    
    // Stage colors
    private let stageColors: [Artist.Stage: Color] = [
        .forest: Color.purple,
        .village: Color.orange,
        .forestFleadh: Color.blue,
        .perfectDay: Color.green,
        .ibizaRewind: Color.pink,
        .vip: Color.yellow
    ]
    
    // 5-minute intervals for precise positioning
    private var timeIntervals: [String] {
        switch selectedDay {
        case .friday:
            return generateTimeIntervals(from: "16:00", to: "02:00")
        case .saturday, .sunday:
            return generateTimeIntervals(from: "12:00", to: "02:00")
        }
    }
    
    // Time labels for display (every 30 minutes)
    private var timeLabels: [String] {
        switch selectedDay {
        case .friday:
            return [
                "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30", "00:00", "00:30", "01:00", "01:30", "02:00"
            ]
        case .saturday, .sunday:
            return [
                "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30", "00:00", "00:30", "01:00", "01:30", "02:00"
            ]
        }
    }
    
    private func generateTimeIntervals(from startTime: String, to endTime: String) -> [String] {
        var intervals: [String] = []
        let startMinutes = timeToMinutes(startTime)
        let endMinutes = timeToMinutes(endTime)
        
        var currentMinutes = startMinutes
        while currentMinutes <= endMinutes {
            let hour = currentMinutes / 60
            let minute = currentMinutes % 60
            let timeString = String(format: "%02d:%02d", hour, minute)
            intervals.append(timeString)
            currentMinutes += 5
        }
        
        return intervals
    }
    
    // Stage order
    private let stageOrder: [Artist.Stage] = [.forest, .village, .forestFleadh, .perfectDay, .ibizaRewind, .vip]
    
    var dayArtists: [Artist] {
        return Artist.allArtists.filter { $0.performanceDay == selectedDay }.sorted()
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
                
                Text("Timetable")
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
            
            // Day Selection
            DaySelectorView(selectedDay: $selectedDay)
            
            // Timetable Grid
            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Time header row
                        HStack(spacing: 0) {
                            // Empty corner cell
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 120, height: 40)
                            
                            // Empty space to shift labels left
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 60, height: 40)
                            
                            // Time labels (every 30 minutes)
                            ForEach(timeLabels, id: \.self) { time in
                                Text(time)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 60, height: 40, alignment: .leading)
                                    .padding(.leading, 4)
                                    .background(Color.black.opacity(0.3))
                                    .overlay(
                                        Rectangle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 1)
                                            .offset(x: -0.5),
                                        alignment: .leading
                                    )
                            }
                        }
                        .id("timetable-start")
                    
                        // Stage rows
                        ForEach(stageOrder, id: \.self) { stage in
                            StageRowView(
                                stage: stage,
                                stageColors: stageColors,
                                timeIntervals: timeIntervals,
                                artists: getArtistsForStage(stage),
                                favoriteManager: favoriteManager
                            )
                        }
                    }
                }
                .onChange(of: selectedDay) { _, _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("timetable-start", anchor: .topLeading)
                    }
                }
            }
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
    }
    
    private func getArtistsForStage(_ stage: Artist.Stage) -> [Artist] {
        return dayArtists.filter { $0.stage == stage }
    }
    
    private func getEventXPosition(for artist: Artist) -> CGFloat {
        let startTime = artist.performanceTime
        let startMinutes = timeToMinutes(startTime)
        
        // Find the 5-minute interval that matches the artist's start time
        for (index, interval) in timeIntervals.enumerated() {
            let intervalMinutes = timeToMinutes(interval)
            if startMinutes == intervalMinutes {
                // Each 5-minute interval is 10px wide, plus 120px offset for stage name column
                return CGFloat(index) * 10 + 120
            }
        }
        
        // If no exact match, find the closest interval
        var closestIndex = 0
        var minDifference = Int.max
        
        for (index, interval) in timeIntervals.enumerated() {
            let intervalMinutes = timeToMinutes(interval)
            let difference = abs(startMinutes - intervalMinutes)
            if difference < minDifference {
                minDifference = difference
                closestIndex = index
            }
        }
        
        // Each 5-minute interval is 10px wide, plus 120px offset for stage name column
        return CGFloat(closestIndex) * 10 + 120
    }
    
    // Helper function to convert time string to minutes
    private func timeToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 0
        }
        
        // If hour is 00-05, treat it as late night (24-29)
        let adjustedHour = (hour >= 0 && hour <= 5) ? hour + 24 : hour
        return adjustedHour * 60 + minute
    }
}

struct TimetableEventCard: View {
    let artist: Artist
    let isFavorited: Bool
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(artist.name)
                .font(.system(size: 14, weight: isFavorited ? .bold : .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(artist.performanceTime)-\(artist.performanceEndTime)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
            
            if isFavorited {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .scaleEffect(isFavorited ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isFavorited)
            }
        }
        .padding(6)
        .frame(width: getEventWidth(), height: 80, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isFavorited ? Color.red.opacity(0.4) : Color.white.opacity(0.2),
                            isFavorited ? Color.red.opacity(0.2) : Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isFavorited ? Color.red.opacity(0.8) : Color.white.opacity(0.3),
                            lineWidth: isFavorited ? 2 : 1
                        )
                )
                .shadow(color: isFavorited ? Color.red.opacity(0.3) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
    
    private func getEventWidth() -> CGFloat {
        let startMinutes = timeToMinutes(artist.performanceTime)
        let endMinutes = timeToMinutes(artist.performanceEndTime)
        let duration = endMinutes - startMinutes
        
        // Each 5-minute interval is 10px wide, so each minute is 2px
        let width = CGFloat(duration) * 2.0 - 4 // Subtract 4px for padding
        
        return max(60, width) // Increased minimum width for better text display
    }
    
    private func timeToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 0
        }
        
        let adjustedHour = (hour >= 0 && hour <= 5) ? hour + 24 : hour
        return adjustedHour * 60 + minute
    }
}

// MARK: - Helper Views

struct GridBackgroundView: View {
    let timeIntervals: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(timeIntervals, id: \.self) { time in
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 10, height: 90) // 10px per 5-minute interval
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 1)
                            .offset(x: -0.5)
                            .shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: 0),
                        alignment: .leading
                    )
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                            .offset(y: -0.5)
                            .shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: 0),
                        alignment: .top
                    )
            }
        }
    }
}

struct ArtistEventsView: View {
    let artists: [Artist]
    let favoriteManager: FavoriteManager
    let timeIntervals: [String]
    
    var body: some View {
        ForEach(artists, id: \.id) { artist in
                                                    TimetableEventCard(artist: artist, isFavorited: favoriteManager.isFavorited(artist))
                                            .position(
                                                x: getEventXPosition(for: artist),
                                                y: 45
                                            )
                .zIndex(favoriteManager.isFavorited(artist) ? 1 : 0)
        }
    }
    
    private func getEventXPosition(for artist: Artist) -> CGFloat {
        let startTime = artist.performanceTime
        let startMinutes = timeToMinutes(startTime)
        
        // Find the 5-minute interval that matches the artist's start time
        for (index, interval) in timeIntervals.enumerated() {
            let intervalMinutes = timeToMinutes(interval)
            if startMinutes == intervalMinutes {
                // Each 5-minute interval is 10px wide, plus 120px offset for stage name column
                return CGFloat(index) * 10 + 120
            }
        }
        
        // If no exact match, find the closest interval
        var closestIndex = 0
        var minDifference = Int.max
        
        for (index, interval) in timeIntervals.enumerated() {
            let intervalMinutes = timeToMinutes(interval)
            let difference = abs(startMinutes - intervalMinutes)
            if difference < minDifference {
                minDifference = difference
                closestIndex = index
            }
        }
        
        // Each 5-minute interval is 10px wide, plus 120px offset for stage name column
        return CGFloat(closestIndex) * 10 + 120
    }
    
    private func timeToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 0
        }
        
        // If hour is 00-05, treat it as late night (24-29)
        let adjustedHour = (hour >= 0 && hour <= 5) ? hour + 24 : hour
        return adjustedHour * 60 + minute
    }
    

}

#Preview {
    TimetableView()
        .environmentObject(FavoriteManager())
}

// MARK: - Day Selector View

struct DaySelectorView: View {
    @Binding var selectedDay: Artist.PerformanceDay
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([Artist.PerformanceDay.friday, .saturday, .sunday], id: \.self) { day in
                DayButton(day: day, isSelected: selectedDay == day) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDay = day
                    }
                }
            }
        }
        .background(Color.black.opacity(0.2))
    }
}

struct DayButton: View {
    let day: Artist.PerformanceDay
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(day.rawValue.components(separatedBy: ",")[0].uppercased())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.3), value: isSelected)
                }
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Stage Row View

struct StageRowView: View {
    let stage: Artist.Stage
    let stageColors: [Artist.Stage: Color]
    let timeIntervals: [String]
    let artists: [Artist]
    let favoriteManager: FavoriteManager
    
    var body: some View {
        HStack(spacing: 0) {
            // Stage name
            StageNameView(stage: stage, color: stageColors[stage] ?? .white)
            
            // Time slots for this stage
            ZStack {
                // Grid background
                GridBackgroundView(timeIntervals: timeIntervals)
                
                // Artist events
                ArtistEventsView(
                    artists: artists,
                    favoriteManager: favoriteManager,
                    timeIntervals: timeIntervals
                )
            }
        }
    }
}

struct StageNameView: View {
    let stage: Artist.Stage
    let color: Color
    
    var body: some View {
        Text(stage.rawValue.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(color)
            .frame(width: 120, height: 90, alignment: .leading)
            .padding(.leading, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: color.opacity(0.2), radius: 2, x: 0, y: 1)
            .background(Color.black.opacity(0.3))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .offset(y: -0.5),
                alignment: .top
            )
    }
} 