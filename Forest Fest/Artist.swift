import Foundation

struct Artist: Identifiable, Comparable {
    var id: String {
        // Create a deterministic ID by combining name and stage
        "\(name)-\(stage.rawValue)".lowercased().replacingOccurrences(of: " ", with: "-")
    }
    let name: String
    let imageName: String
    let stage: Stage
    let performanceDay: PerformanceDay
    let performanceTime: String // Format: "HH:mm"
    let performanceEndTime: String // Format: "HH:mm"
    
    enum Stage: String {
        case forest = "Forest Stage"
        case village = "Village Stage"
        case forestFleadh = "Forest Fleadh Stage"
        case perfectDay = "Perfect Day Stage"
        case ibizaRewind = "Ibiza Rewind Tent"
        case vip = "VIP Stage"
    }
    
    enum PerformanceDay: String, Comparable {
        case friday = "Friday, July 25"
        case saturday = "Saturday, July 26"
        case sunday = "Sunday, July 27"
        
        static func < (lhs: PerformanceDay, rhs: PerformanceDay) -> Bool {
            let order: [PerformanceDay] = [.friday, .saturday, .sunday]
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }
    }
    
    // Implement Comparable for Artist
    static func < (lhs: Artist, rhs: Artist) -> Bool {
        if lhs.performanceDay != rhs.performanceDay {
            return lhs.performanceDay < rhs.performanceDay
        }
        return lhs.sortableMinutes < rhs.sortableMinutes
    }
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helper computed property for duration
    var duration: String {
        // Calculate duration between start and end time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let startDate = formatter.date(from: performanceTime),
              let endDate = formatter.date(from: performanceEndTime) else {
            return "Unknown"
        }
        
        let duration = endDate.timeIntervalSince(startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Helper computed property to check if performances overlap
    func overlaps(with other: Artist) -> Bool {
        guard performanceDay == other.performanceDay else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let start1 = formatter.date(from: performanceTime),
              let end1 = formatter.date(from: performanceEndTime),
              let start2 = formatter.date(from: other.performanceTime),
              let end2 = formatter.date(from: other.performanceEndTime) else {
            return false
        }
        
        return start1 < end2 && start2 < end1
    }
    
    // Helper computed property for sorting - treats times after midnight as late night
    var sortableTime: String {
        let components = performanceTime.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return performanceTime
        }
        
        // If hour is 00-05, treat it as late night (24-29)
        if hour >= 0 && hour <= 5 {
            let adjustedHour = hour + 24
            return String(format: "%02d:%02d", adjustedHour, minute)
        }
        
        return performanceTime
    }
    
    // Helper function to convert time string to minutes for proper sorting
    private func timeToMinutes(_ timeString: String) -> Int {
        // Handle both colon and dot separators
        let components = timeString.split(separator: ":").count > 1 ? 
            timeString.split(separator: ":") : 
            timeString.split(separator: ".")
        
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 0
        }
        
        // If hour is 00-05, treat it as late night (24-29)
        let adjustedHour = (hour >= 0 && hour <= 5) ? hour + 24 : hour
        return adjustedHour * 60 + minute
    }
    
    // Computed property for sorting that properly handles midnight crossing
    var sortableMinutes: Int {
        return timeToMinutes(performanceTime)
    }
}

extension Artist {
    static var allArtists: [Artist] {
        return (forestStageArtists + perfectDayStageArtists + villageStageArtists + forestFleadhStageArtists + ibizaRewindStageArtists + vipStageArtists).sorted()
    }
    
    static let forestStageArtists = [
        // Friday Forest Stage (chronological order)
        Artist(name: "Something Happens", imageName: "something-happens", stage: .forest, performanceDay: .friday, performanceTime: "17:00", performanceEndTime: "18:00"),
        Artist(name: "Tom Meighan", imageName: "tom-meighan", stage: .forest, performanceDay: .friday, performanceTime: "18:40", performanceEndTime: "19:40"),
        Artist(name: "Franz Ferdinand", imageName: "franz-ferdinand", stage: .forest, performanceDay: .friday, performanceTime: "20:20", performanceEndTime: "21:50"),
        Artist(name: "The Dandy Warhols", imageName: "the-dandy-warhols", stage: .forest, performanceDay: .friday, performanceTime: "22:30", performanceEndTime: "23:30"),
        Artist(name: "Live Forever Oasis", imageName: "live-forever-oasis", stage: .forest, performanceDay: .friday, performanceTime: "00:00", performanceEndTime: "01:00"),
        
        // Saturday Forest Stage (chronological order)
        Artist(name: "Thumper", imageName: "thumper", stage: .forest, performanceDay: .saturday, performanceTime: "12:35", performanceEndTime: "13:35"),
        Artist(name: "Aoife Destruction and The Nilz", imageName: "aoife-destruction-and-the-nilz", stage: .forest, performanceDay: .saturday, performanceTime: "14:10", performanceEndTime: "14:50"),
        Artist(name: "Therapy?", imageName: "therapy", stage: .forest, performanceDay: .saturday, performanceTime: "15:20", performanceEndTime: "16:20"),
        Artist(name: "Peter Hook and The Light", imageName: "peter-hook-the-light", stage: .forest, performanceDay: .saturday, performanceTime: "17:00", performanceEndTime: "18:00"),
        Artist(name: "The Stranglers", imageName: "the-stranglers", stage: .forest, performanceDay: .saturday, performanceTime: "18:40", performanceEndTime: "19:40"),
        Artist(name: "Kula Shaker", imageName: "kula-shaker", stage: .forest, performanceDay: .saturday, performanceTime: "20:20", performanceEndTime: "21:20"),
        Artist(name: "Manic Street Preachers", imageName: "manic-street-preachers", stage: .forest, performanceDay: .saturday, performanceTime: "22:00", performanceEndTime: "23:30"),
        Artist(name: "Orbital", imageName: "orbital", stage: .forest, performanceDay: .saturday, performanceTime: "00:15", performanceEndTime: "01:45"),
        
        // Sunday Forest Stage (chronological order)
        Artist(name: "Rattle & Hum", imageName: "rattle-and-hum", stage: .forest, performanceDay: .sunday, performanceTime: "12:00", performanceEndTime: "13:00"),
        Artist(name: "Nick Lowe", imageName: "nick-lowe", stage: .forest, performanceDay: .sunday, performanceTime: "13:30", performanceEndTime: "14:30"),
        Artist(name: "Bad Manners", imageName: "bad-manners", stage: .forest, performanceDay: .sunday, performanceTime: "15:10", performanceEndTime: "16:10"),
        Artist(name: "Jack L", imageName: "jack-lukeman", stage: .forest, performanceDay: .sunday, performanceTime: "16:50", performanceEndTime: "17:50"),
        Artist(name: "Tony Hadley", imageName: "tony-hadley", stage: .forest, performanceDay: .sunday, performanceTime: "18:30", performanceEndTime: "19:50"),
        Artist(name: "Travis", imageName: "travis-band", stage: .forest, performanceDay: .sunday, performanceTime: "20:30", performanceEndTime: "22:00"),
        Artist(name: "Qween", imageName: "qween", stage: .forest, performanceDay: .sunday, performanceTime: "23:00", performanceEndTime: "00:00")
    ]
    
    static let perfectDayStageArtists = [
        // Friday Perfect Day Stage (chronological order)
        Artist(name: "The Jury", imageName: "the-jury", stage: .perfectDay, performanceDay: .friday, performanceTime: "16:40", performanceEndTime: "17:25"),
        Artist(name: "Shark School", imageName: "shark-school", stage: .perfectDay, performanceDay: .friday, performanceTime: "17:45", performanceEndTime: "18:30"),
        Artist(name: "The Jobseekers", imageName: "jobseekerz", stage: .perfectDay, performanceDay: .friday, performanceTime: "18:50", performanceEndTime: "19:35"),
        Artist(name: "Intercom Heights", imageName: "intercom-heights", stage: .perfectDay, performanceDay: .friday, performanceTime: "19:55", performanceEndTime: "20:40"),
        Artist(name: "Seattle Grunge Experience", imageName: "seattle-grunge-experience", stage: .perfectDay, performanceDay: .friday, performanceTime: "21:00", performanceEndTime: "21:45"),
        Artist(name: "The Luna Boys", imageName: "the-luna-boys", stage: .perfectDay, performanceDay: .friday, performanceTime: "22:05", performanceEndTime: "22:50"),
        Artist(name: "Risky Business", imageName: "risky-business", stage: .perfectDay, performanceDay: .friday, performanceTime: "23:10", performanceEndTime: "23:55"),
        Artist(name: "The Deadlians", imageName: "the-deadlians", stage: .perfectDay, performanceDay: .friday, performanceTime: "00:15", performanceEndTime: "01:00"),
        Artist(name: "Thin Az Lizzy", imageName: "thin-az-lizzy", stage: .perfectDay, performanceDay: .friday, performanceTime: "01:15", performanceEndTime: "02:00"),
        
        // Saturday Perfect Day Stage (chronological order)
        Artist(name: "Houston Death Ray", imageName: "houston-death-ray", stage: .perfectDay, performanceDay: .saturday, performanceTime: "12:20", performanceEndTime: "13:05"),
        Artist(name: "Southern Freud", imageName: "southern-freud", stage: .perfectDay, performanceDay: .saturday, performanceTime: "13:25", performanceEndTime: "14:10"),
        Artist(name: "The Magic Mod", imageName: "the-magic-mod", stage: .perfectDay, performanceDay: .saturday, performanceTime: "14:30", performanceEndTime: "15:00"),
        Artist(name: "Kiera Dignam", imageName: "kiera-dignam", stage: .perfectDay, performanceDay: .saturday, performanceTime: "15:20", performanceEndTime: "16:05"),
        Artist(name: "Dopamine", imageName: "dopamine", stage: .perfectDay, performanceDay: .saturday, performanceTime: "16:25", performanceEndTime: "17:05"),
        Artist(name: "Fake Friends", imageName: "fake-friends", stage: .perfectDay, performanceDay: .saturday, performanceTime: "17:25", performanceEndTime: "18:05"),
        Artist(name: "The Classic Beatles", imageName: "the-classic-beatles", stage: .perfectDay, performanceDay: .saturday, performanceTime: "18:25", performanceEndTime: "19:25"),
        Artist(name: "Apollo Junction", imageName: "apollo-junction", stage: .perfectDay, performanceDay: .saturday, performanceTime: "19:45", performanceEndTime: "20:25"),
        Artist(name: "The Manatees", imageName: "the-manatees", stage: .perfectDay, performanceDay: .saturday, performanceTime: "20:45", performanceEndTime: "21:30"),
        Artist(name: "Dutch Criminal Record", imageName: "dutch-criminal-record", stage: .perfectDay, performanceDay: .saturday, performanceTime: "21:50", performanceEndTime: "22:35"),
        Artist(name: "Post-Party", imageName: "post-party", stage: .perfectDay, performanceDay: .saturday, performanceTime: "22:55", performanceEndTime: "23:40"),
        Artist(name: "Walk the Line", imageName: "walk-the-line", stage: .perfectDay, performanceDay: .saturday, performanceTime: "00:00", performanceEndTime: "01:30"),
        
        // Sunday Perfect Day Stage (chronological order)
        Artist(name: "MOA", imageName: "moa", stage: .perfectDay, performanceDay: .sunday, performanceTime: "12:15", performanceEndTime: "12:45"),
        Artist(name: "Fizzy Orange", imageName: "fizzy-orange", stage: .perfectDay, performanceDay: .sunday, performanceTime: "13:05", performanceEndTime: "13:45"),
        Artist(name: "thanks mom", imageName: "thanks-mom", stage: .perfectDay, performanceDay: .sunday, performanceTime: "14:05", performanceEndTime: "14:45"),
        Artist(name: "Strength in Numbers", imageName: "strength-in-numbers", stage: .perfectDay, performanceDay: .sunday, performanceTime: "15:05", performanceEndTime: "15:45"),
        Artist(name: "Basht.", imageName: "basht", stage: .perfectDay, performanceDay: .sunday, performanceTime: "16:05", performanceEndTime: "16:45"),
        Artist(name: "Glasshouse Performs: The Velvet Underground", imageName: "glasshouse", stage: .perfectDay, performanceDay: .sunday, performanceTime: "17:05", performanceEndTime: "17:50"),
        Artist(name: "The Youth Play", imageName: "the-youthplay", stage: .perfectDay, performanceDay: .sunday, performanceTime: "18:10", performanceEndTime: "18:55"),
        Artist(name: "Motion Sickness", imageName: "motion-sickness", stage: .perfectDay, performanceDay: .sunday, performanceTime: "19:15", performanceEndTime: "20:00"),
        Artist(name: "Pogueology", imageName: "pogueology", stage: .perfectDay, performanceDay: .sunday, performanceTime: "20:20", performanceEndTime: "21:05"),
        Artist(name: "Grooveline", imageName: "grooveline", stage: .perfectDay, performanceDay: .sunday, performanceTime: "21:25", performanceEndTime: "22:10"),
        Artist(name: "Sack", imageName: "sack", stage: .perfectDay, performanceDay: .sunday, performanceTime: "22:30", performanceEndTime: "23:20"),
        Artist(name: "The Drive.", imageName: "the-drive", stage: .perfectDay, performanceDay: .sunday, performanceTime: "23:40", performanceEndTime: "00:20")
    ]
    
    static let villageStageArtists = [
        // Friday Village Stage (chronological order)
        Artist(name: "The Valves", imageName: "the-valves", stage: .village, performanceDay: .friday, performanceTime: "16:00", performanceEndTime: "17:00"),
        Artist(name: "Harvest", imageName: "harvest", stage: .village, performanceDay: .friday, performanceTime: "17:30", performanceEndTime: "18:30"),
        Artist(name: "Cry Before Dawn", imageName: "cry-before-dawn", stage: .village, performanceDay: .friday, performanceTime: "19:00", performanceEndTime: "20:00"),
        Artist(name: "The 4 of Us", imageName: "the-4-of-us", stage: .village, performanceDay: .friday, performanceTime: "20:30", performanceEndTime: "21:30"),
        Artist(name: "The Farm", imageName: "the-farm", stage: .village, performanceDay: .friday, performanceTime: "22:00", performanceEndTime: "23:00"),
        Artist(name: "Alabama 3", imageName: "alabama-3", stage: .village, performanceDay: .friday, performanceTime: "23:30", performanceEndTime: "00:45"),
        Artist(name: "Daft Punk Tribute", imageName: "daft-punk-tribute", stage: .village, performanceDay: .friday, performanceTime: "01:00", performanceEndTime: "02:00"),
        
        // Saturday Village Stage (chronological order)
        Artist(name: "Dylan Flynn & The Dead Poets", imageName: "dylan-flynn-the-dead-poets", stage: .village, performanceDay: .saturday, performanceTime: "12:15", performanceEndTime: "13:00"),
        Artist(name: "The Coathanger Solution", imageName: "the-coathanger-solution", stage: .village, performanceDay: .saturday, performanceTime: "13:20", performanceEndTime: "14:05"),
        Artist(name: "These Charming Men", imageName: "these-charming-men", stage: .village, performanceDay: .saturday, performanceTime: "14:30", performanceEndTime: "15:30"),
        Artist(name: "Dirty Blonde", imageName: "dirty-blonde", stage: .village, performanceDay: .saturday, performanceTime: "16:00", performanceEndTime: "17:00"),
        Artist(name: "Coach Party", imageName: "coach-party", stage: .village, performanceDay: .saturday, performanceTime: "17:30", performanceEndTime: "18:30"),
        Artist(name: "Pillow Queens", imageName: "pillow-queens", stage: .village, performanceDay: .saturday, performanceTime: "19:00", performanceEndTime: "20:00"),
        Artist(name: "Kerbdog", imageName: "kerbdog", stage: .village, performanceDay: .saturday, performanceTime: "20:30", performanceEndTime: "21:30"),
        Artist(name: "Reef", imageName: "reef", stage: .village, performanceDay: .saturday, performanceTime: "22:00", performanceEndTime: "23:00"),
        Artist(name: "Teenage Fanclub", imageName: "teenage-fanclub", stage: .village, performanceDay: .saturday, performanceTime: "23:30", performanceEndTime: "00:40"),
        Artist(name: "The Riptide Movement", imageName: "the-riptide-movement", stage: .village, performanceDay: .saturday, performanceTime: "01:10", performanceEndTime: "02:00"),
        
        // Sunday Village Stage (chronological order)
        Artist(name: "Ryan Sheridan", imageName: "ryan-sheridan", stage: .village, performanceDay: .sunday, performanceTime: "12:15", performanceEndTime: "13:05"),
        Artist(name: "Paddy Casey", imageName: "paddy-casey", stage: .village, performanceDay: .sunday, performanceTime: "13:35", performanceEndTime: "14:25"),
        Artist(name: "Bingo Loco", imageName: "bingo-loco", stage: .village, performanceDay: .sunday, performanceTime: "14:55", performanceEndTime: "16:25"),
        Artist(name: "Andrew Strong", imageName: "andrew-strong", stage: .village, performanceDay: .sunday, performanceTime: "16:55", performanceEndTime: "17:45"),
        Artist(name: "Robert Finley", imageName: "robert-finley", stage: .village, performanceDay: .sunday, performanceTime: "18:15", performanceEndTime: "19:15"),
        Artist(name: "Hermitage Green", imageName: "hermitage-green", stage: .village, performanceDay: .sunday, performanceTime: "19:45", performanceEndTime: "20:45"),
        Artist(name: "Billy Bragg", imageName: "billy-bragg", stage: .village, performanceDay: .sunday, performanceTime: "21:15", performanceEndTime: "22:30"),
        Artist(name: "The Magic Numbers", imageName: "the-magic-number", stage: .village, performanceDay: .sunday, performanceTime: "23:00", performanceEndTime: "00:00")
    ]
    
    static let forestFleadhStageArtists = [
        // Friday Forest Fleadh Stage (chronological order)
        Artist(name: "Madra Salach", imageName: "madra-salach", stage: .forestFleadh, performanceDay: .friday, performanceTime: "16:20", performanceEndTime: "17:00"),
        Artist(name: "Meadhbh Hayes", imageName: "meadhbh-hayes", stage: .forestFleadh, performanceDay: .friday, performanceTime: "17:20", performanceEndTime: "18:00"),
        Artist(name: "Alltacht", imageName: "alltacht", stage: .forestFleadh, performanceDay: .friday, performanceTime: "18:20", performanceEndTime: "19:10"),
        Artist(name: "Cua", imageName: "cua", stage: .forestFleadh, performanceDay: .friday, performanceTime: "19:30", performanceEndTime: "20:20"),
        Artist(name: "Laura Jo", imageName: "laura-jo", stage: .forestFleadh, performanceDay: .friday, performanceTime: "20:40", performanceEndTime: "21:30"),
        Artist(name: "Moxie", imageName: "moxie", stage: .forestFleadh, performanceDay: .friday, performanceTime: "21:50", performanceEndTime: "22:40"),
        Artist(name: "Stocktons Wing", imageName: "stocktons-wing", stage: .forestFleadh, performanceDay: .friday, performanceTime: "23:00", performanceEndTime: "00:00"),
        
        // Saturday Forest Fleadh Stage (chronological order)
        Artist(name: "Music Generation Laois Trad Orchestra", imageName: "music-generation-laois-trad-orchestra", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "12:00", performanceEndTime: "12:45"),
        Artist(name: "Chris Comhaill", imageName: "chris-comhaill", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "13:15", performanceEndTime: "14:00"),
        Artist(name: "Cormac Looby", imageName: "cormac-looby", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "14:15", performanceEndTime: "15:00"),
        Artist(name: "The Oars", imageName: "the-oars", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "15:15", performanceEndTime: "16:00"),
        Artist(name: "Kevin Conneff Dublin Trio", imageName: "kevin-coneff-the-chieftains", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "16:15", performanceEndTime: "17:00"),
        Artist(name: "Buille", imageName: "buille", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "17:15", performanceEndTime: "18:00"),
        Artist(name: "Eric de Buitleir", imageName: "eric-de-buitleir", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "18:15", performanceEndTime: "19:00"),
        Artist(name: "Mary Coughlan", imageName: "mary-coughlan", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "19:30", performanceEndTime: "20:30"),
        Artist(name: "Sharon Shannon", imageName: "sharon-shannon", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "21:00", performanceEndTime: "22:00"),
        Artist(name: "Beoga", imageName: "beoga", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "22:30", performanceEndTime: "23:30"),
        Artist(name: "Kan", imageName: "kan", stage: .forestFleadh, performanceDay: .saturday, performanceTime: "00:00", performanceEndTime: "01:00"),
        
        // Sunday Forest Fleadh Stage (chronological order)
        Artist(name: "Set Dancing W Maureen Culleton & Irish Dancing from Scoil Rince Ni Anglais", imageName: "set-dancing", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "12:00", performanceEndTime: "12:40"),
        Artist(name: "Eva Coyle and Band", imageName: "eva-coyle", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "13:00", performanceEndTime: "14:00"),
        Artist(name: "Seán Lyons and Eva Carroll", imageName: "sean-lyons-and-eva-carroll", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "14:30", performanceEndTime: "15:15"),
        Artist(name: "Frankie Gavin and De Dannan", imageName: "frankie-gavin-de-dannan", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "15:45", performanceEndTime: "16:45"),
        Artist(name: "Buioch", imageName: "buioch-trad", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "17:00", performanceEndTime: "17:45"),
        Artist(name: "Niall McCabe", imageName: "niall-mccabe", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "18:00", performanceEndTime: "19:00"),
        Artist(name: "Freddie White", imageName: "freddie-white", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "19:30", performanceEndTime: "20:30"),
        Artist(name: "Hunger of the Skin - Brian Finnegan", imageName: "brian-finnegan-with-the-hunger-of-the-skin-band", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "21:00", performanceEndTime: "22:00"),
        Artist(name: "The Complete Stone Roses", imageName: "the-complete-stone-roses", stage: .forestFleadh, performanceDay: .sunday, performanceTime: "22:30", performanceEndTime: "23:30")
    ]
    
    static let ibizaRewindStageArtists = [
        // Friday Ibiza Rewind Tent (chronological order)
        Artist(name: "Danny Kay Ibiza, Lauren (Saxophone)", imageName: "danny-kay-ibiza", stage: .ibizaRewind, performanceDay: .friday, performanceTime: "16:00", performanceEndTime: "17:00"),
        Artist(name: "Alan Prosser", imageName: "alan-prosser", stage: .ibizaRewind, performanceDay: .friday, performanceTime: "17:00", performanceEndTime: "18:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .friday, performanceTime: "18:00", performanceEndTime: "22:00"),
        Artist(name: "Terry Farley", imageName: "terry-farley", stage: .ibizaRewind, performanceDay: .friday, performanceTime: "20:00", performanceEndTime: "22:00"),
        Artist(name: "X-Press 2", imageName: "x-press-2", stage: .ibizaRewind, performanceDay: .friday, performanceTime: "22:00", performanceEndTime: "00:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .friday, performanceTime: "00:00", performanceEndTime: "02:00"),
        
        // Saturday Ibiza Rewind Tent (chronological order)
        Artist(name: "Danny Kay Ibiza, David H (Percussion), Lauren (Saxophone)", imageName: "danny-kay-ibiza", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "12:00", performanceEndTime: "13:00"),
        Artist(name: "Nick Coles", imageName: "nick-coles", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "13:00", performanceEndTime: "14:00"),
        Artist(name: "Alan Prosser", imageName: "alan-prosser", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "14:00", performanceEndTime: "15:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "15:00", performanceEndTime: "17:00"),
        Artist(name: "Mr C", imageName: "mr-c", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "17:00", performanceEndTime: "19:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "19:00", performanceEndTime: "21:00"),
        Artist(name: "Jam El Mar", imageName: "jam-el-mar", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "21:00", performanceEndTime: "23:00"),
        Artist(name: "DJ Pippi", imageName: "dj-pippi", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "23:00", performanceEndTime: "01:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .saturday, performanceTime: "01:00", performanceEndTime: "02:00"),
        
        // Sunday Ibiza Rewind Tent (chronological order)
        Artist(name: "Danny Kay Ibiza, David H (Percussion)", imageName: "danny-kay-ibiza", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "12:00", performanceEndTime: "13:00"),
        Artist(name: "Alan Prosser", imageName: "alan-prosser", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "13:00", performanceEndTime: "15:00"),
        Artist(name: "DJ Sean", imageName: "dj-sean", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "15:00", performanceEndTime: "15:40"),
        Artist(name: "Nick Coles", imageName: "nick-coles", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "15:40", performanceEndTime: "16:40"),
        Artist(name: "Lange and The Morrighan", imageName: "lange", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "16:40", performanceEndTime: "18:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "18:00", performanceEndTime: "19:00"),
        Artist(name: "Mr.C", imageName: "mr-c", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "19:00", performanceEndTime: "22:00"),
        Artist(name: "Gee Moore", imageName: "gee-moore", stage: .ibizaRewind, performanceDay: .sunday, performanceTime: "22:00", performanceEndTime: "00:00")
    ]
    
    static let vipStageArtists = [
        // Friday VIP Stage (chronological order)
        Artist(name: "Half The Truth", imageName: "half-the-truth", stage: .vip, performanceDay: .friday, performanceTime: "00:00", performanceEndTime: "01:45"),
        
        // Saturday VIP Stage (chronological order)
        Artist(name: "The Legendary Drama Kings", imageName: "the-legendary-drama-kings", stage: .vip, performanceDay: .saturday, performanceTime: "18:00", performanceEndTime: "18:45"),
        Artist(name: "The Magic Mod", imageName: "the-magic-mod", stage: .vip, performanceDay: .saturday, performanceTime: "19:00", performanceEndTime: "19:30"),
        Artist(name: "Strength in Numbers", imageName: "strength-in-numbers", stage: .vip, performanceDay: .saturday, performanceTime: "19:45", performanceEndTime: "20:00"),
        Artist(name: "The Valves", imageName: "the-valves", stage: .vip, performanceDay: .saturday, performanceTime: "23:45", performanceEndTime: "01:00"),
        
        // Sunday VIP Stage (chronological order)
        Artist(name: "The Valves", imageName: "the-valves", stage: .vip, performanceDay: .sunday, performanceTime: "19:00", performanceEndTime: "20:00")
    ]
} 
