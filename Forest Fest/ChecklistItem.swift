import Foundation

enum ChecklistItemState: String, CaseIterable, Codable {
    case notPacked = "Not Packed"
    case packed = "Packed"
    case notNeeded = "Not Needed"
    
    var color: String {
        switch self {
        case .notPacked:
            return "red"
        case .packed:
            return "green"
        case .notNeeded:
            return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .notPacked:
            return "circle"
        case .packed:
            return "checkmark.circle.fill"
        case .notNeeded:
            return "minus.circle"
        }
    }
}

struct ChecklistItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: String
    let description: String
    var state: ChecklistItemState
    
    init(name: String, category: String, description: String, state: ChecklistItemState = .notPacked) {
        self.name = name
        self.category = category
        self.description = description
        self.state = state
    }
} 