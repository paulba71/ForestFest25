import Foundation
import SwiftUI

class ChecklistManager: ObservableObject {
    @Published var items: [ChecklistItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let checklistKey = "festivalChecklist"
    private let checklistVersionKey = "festivalChecklistVersion"
    private let currentVersion = 3
    
    init() {
        loadChecklist()
        if items.isEmpty {
            createDefaultChecklist()
            userDefaults.set(currentVersion, forKey: checklistVersionKey)
        } else {
            // Check if we need to update the checklist
            let savedVersion = userDefaults.integer(forKey: checklistVersionKey)
            if savedVersion < currentVersion {
                addNewItemsToExistingChecklist()
                userDefaults.set(currentVersion, forKey: checklistVersionKey)
            }
        }
    }
    
    private func createDefaultChecklist() {
        items = [
            // Essential Items
            ChecklistItem(name: "Festival Tickets", category: "Essential", description: "Your entry tickets to the festival"),
            ChecklistItem(name: "ID/Passport", category: "Essential", description: "Valid identification"),
            ChecklistItem(name: "Cash", category: "Essential", description: "Cash for food, drinks, and vendors"),
            ChecklistItem(name: "Phone", category: "Essential", description: "Mobile phone with charger"),
            
            // Camping Gear
            ChecklistItem(name: "Tent", category: "Camping", description: "Waterproof tent with poles and pegs"),
            ChecklistItem(name: "Sleeping Bag", category: "Camping", description: "Warm sleeping bag suitable for weather"),
            ChecklistItem(name: "Sleeping Mat", category: "Camping", description: "Insulation from ground"),
            ChecklistItem(name: "Pillow", category: "Camping", description: "Comfortable pillow for sleeping"),
            ChecklistItem(name: "Camping Chair", category: "Camping", description: "Portable chair for comfort"),
            ChecklistItem(name: "Trolley", category: "Camping", description: "Wheeled trolley for carrying gear"),
            ChecklistItem(name: "Bungies", category: "Camping", description: "Bungee cords for securing trolley load"),
            
            // Clothing
            ChecklistItem(name: "Weather-Appropriate Clothes", category: "Clothing", description: "Clothes for all weather conditions"),
            ChecklistItem(name: "Rain Jacket", category: "Clothing", description: "Waterproof jacket"),
            ChecklistItem(name: "Warm Layers", category: "Clothing", description: "Sweaters, hoodies for cold evenings"),
            ChecklistItem(name: "Comfortable Shoes", category: "Clothing", description: "Sturdy, comfortable footwear"),
            ChecklistItem(name: "Bucket Hat", category: "Clothing", description: "Festival bucket hat for sun protection"),
            
            // Electronics
            ChecklistItem(name: "Power Bank", category: "Electronics", description: "Portable charger for devices"),
            ChecklistItem(name: "Phone Charger", category: "Electronics", description: "Charging cable for your phone"),
            ChecklistItem(name: "Camera", category: "Electronics", description: "Camera or phone for photos"),
            ChecklistItem(name: "Headphones", category: "Electronics", description: "For quiet moments and music"),
            ChecklistItem(name: "Torch", category: "Electronics", description: "Flashlight for navigating at night"),
            
            // Food & Drink
            ChecklistItem(name: "Water Bottle", category: "Food & Drink", description: "Reusable water bottle"),
            ChecklistItem(name: "Snacks", category: "Food & Drink", description: "Non-perishable snacks"),
            ChecklistItem(name: "Cooler Box", category: "Food & Drink", description: "Cooler for keeping drinks and food cold"),
            ChecklistItem(name: "Beer", category: "Food & Drink", description: "Your favorite beers for the festival"),
            ChecklistItem(name: "Wine", category: "Food & Drink", description: "Wine for evening relaxation"),
            ChecklistItem(name: "Cups", category: "Food & Drink", description: "Reusable cups for drinks"),
            
            // Health & Safety
            ChecklistItem(name: "First Aid Kit", category: "Health & Safety", description: "Basic medical supplies"),
            ChecklistItem(name: "Dioralite", category: "Health & Safety", description: "Rehydration salts for hangovers"),
            ChecklistItem(name: "Paracetamol", category: "Health & Safety", description: "Pain relief medication"),
            ChecklistItem(name: "Neurofen", category: "Health & Safety", description: "Anti-inflammatory pain relief"),
            ChecklistItem(name: "Sunscreen", category: "Health & Safety", description: "High SPF sunscreen"),
            ChecklistItem(name: "Insect Repellent", category: "Health & Safety", description: "Bug spray"),
            
            // Personal Care
            ChecklistItem(name: "Toothbrush & Toothpaste", category: "Personal Care", description: "Oral hygiene essentials"),
            ChecklistItem(name: "Deodorant", category: "Personal Care", description: "Personal hygiene"),
            ChecklistItem(name: "Wet Wipes", category: "Personal Care", description: "Quick cleaning solution"),
            ChecklistItem(name: "Toilet Paper", category: "Personal Care", description: "Essential for camping"),
            
            // Optional Items
            ChecklistItem(name: "Musical Instruments", category: "Optional", description: "If you plan to jam"),
            ChecklistItem(name: "Books/Magazines", category: "Optional", description: "For downtime reading"),
            ChecklistItem(name: "Games/Cards", category: "Optional", description: "Entertainment for camping"),
            ChecklistItem(name: "Hammock", category: "Optional", description: "For relaxing between sets"),
            ChecklistItem(name: "Flag/Banner", category: "Optional", description: "To mark your campsite")
        ]
        saveChecklist()
    }
    
    func updateItemState(_ item: ChecklistItem, newState: ChecklistItemState) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].state = newState
            saveChecklist()
        }
    }
    
    func addCustomItem(name: String, category: String, description: String) {
        let newItem = ChecklistItem(name: name, category: category, description: description)
        items.append(newItem)
        saveChecklist()
    }
    
    func deleteItem(_ item: ChecklistItem) {
        items.removeAll { $0.id == item.id }
        saveChecklist()
    }
    
    func resetAllItems() {
        for index in items.indices {
            items[index].state = .notPacked
        }
        saveChecklist()
    }
    
    func getProgress() -> (packed: Int, total: Int) {
        let packed = items.filter { $0.state == .packed }.count
        let total = items.filter { $0.state != .notNeeded }.count
        return (packed, total)
    }
    
    func getItemsByCategory() -> [String: [ChecklistItem]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    private func saveChecklist() {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: checklistKey)
        }
    }
    
    private func loadChecklist() {
        if let data = userDefaults.data(forKey: checklistKey),
           let decoded = try? JSONDecoder().decode([ChecklistItem].self, from: data) {
            items = decoded
        }
    }
    
    private func addNewItemsToExistingChecklist() {
        // First, remove any duplicates that might exist
        removeDuplicates()
        
        // Then, update existing items that should be renamed
        if let cashIndex = items.firstIndex(where: { $0.name == "Money/Cards" }) {
            items[cashIndex] = ChecklistItem(name: "Cash", category: "Essential", description: "Cash for food, drinks, and vendors")
        }
        
        if let hatIndex = items.firstIndex(where: { $0.name == "Hat/Sun Protection" }) {
            items[hatIndex] = ChecklistItem(name: "Bucket Hat", category: "Clothing", description: "Festival bucket hat for sun protection")
        }
        
        if let coolerIndex = items.firstIndex(where: { $0.name == "Cooler/Ice" }) {
            items[coolerIndex] = ChecklistItem(name: "Cooler Box", category: "Food & Drink", description: "Cooler for keeping drinks and food cold")
        }
        
        if let medsIndex = items.firstIndex(where: { $0.name == "Medications" }) {
            items[medsIndex] = ChecklistItem(name: "Dioralite", category: "Health & Safety", description: "Rehydration salts for hangovers")
        }
        
        // Then add only the truly new items
        let newItems = [
            ChecklistItem(name: "Trolley", category: "Camping", description: "Wheeled trolley for carrying gear"),
            ChecklistItem(name: "Bungies", category: "Camping", description: "Bungee cords for securing trolley load"),
            ChecklistItem(name: "Torch", category: "Electronics", description: "Flashlight for navigating at night"),
            ChecklistItem(name: "Beer", category: "Food & Drink", description: "Your favorite beers for the festival"),
            ChecklistItem(name: "Wine", category: "Food & Drink", description: "Wine for evening relaxation"),
            ChecklistItem(name: "Cups", category: "Food & Drink", description: "Reusable cups for drinks"),
            ChecklistItem(name: "Paracetamol", category: "Health & Safety", description: "Pain relief medication"),
            ChecklistItem(name: "Neurofen", category: "Health & Safety", description: "Anti-inflammatory pain relief"),
            ChecklistItem(name: "Towel", category: "Personal Care", description: "Towel for showers and general use"),
            ChecklistItem(name: "Flip Flops", category: "Clothing", description: "Flip flops for showers and comfort"),
            ChecklistItem(name: "Runners", category: "Clothing", description: "Comfortable running shoes for walking"),
            ChecklistItem(name: "Wellies", category: "Clothing", description: "Wellington boots for wet weather"),
            ChecklistItem(name: "Swim Shorts", category: "Clothing", description: "Swim shorts for showers"),
            ChecklistItem(name: "Milk", category: "Food & Drink", description: "Milk for tea and coffee"),
            ChecklistItem(name: "Pot Noodles", category: "Food & Drink", description: "Quick and easy meals"),
            ChecklistItem(name: "Breakfast Bars", category: "Food & Drink", description: "Quick breakfast option"),
            ChecklistItem(name: "Kit Kats", category: "Food & Drink", description: "Chocolate snacks for energy")
        ]
        
        // Check if any new items are missing and add them
        for newItem in newItems {
            if !items.contains(where: { $0.name == newItem.name }) {
                items.append(newItem)
            }
        }
        
        saveChecklist()
    }
    
    private func removeDuplicates() {
        var seenNames: Set<String> = []
        items = items.filter { item in
            if seenNames.contains(item.name) {
                return false
            } else {
                seenNames.insert(item.name)
                return true
            }
        }
    }
} 