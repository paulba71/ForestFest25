import SwiftUI

struct ChecklistView: View {
    @StateObject private var checklistManager = ChecklistManager()
    @State private var showingAddItem = false
    @State private var selectedFilter: ChecklistItemState? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Header
                ProgressHeaderView(progress: checklistManager.getProgress())
                
                // Filter Buttons
                FilterButtonsView(selectedFilter: $selectedFilter)
                
                // Checklist Content
                ChecklistContentView(
                    checklistManager: checklistManager,
                    selectedFilter: selectedFilter
                )
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Reset All Items") {
                            checklistManager.resetAllItems()
                        }
                        Button("Show All Items") {
                            selectedFilter = nil
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(checklistManager: checklistManager)
            }
            .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        }
    }
}

struct ProgressHeaderView: View {
    let progress: (packed: Int, total: Int)
    
    private var progressPercentage: Double {
        guard progress.total > 0 else { return 0 }
        return Double(progress.packed) / Double(progress.total)
    }
    
    private var progressText: String {
        let percentage = Int(progressPercentage * 100)
        return "\(percentage)%"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Custom title
            Text("Festival Checklist")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Packing Progress")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(progress.packed) of \(progress.total) items packed")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress.packed)
                    
                    Text(progressText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct FilterButtonsView: View {
    @Binding var selectedFilter: ChecklistItemState?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(title: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                
                ForEach(ChecklistItemState.allCases, id: \.self) { state in
                    FilterButton(
                        title: state.rawValue,
                        isSelected: selectedFilter == state,
                        color: Color.white
                    ) {
                        selectedFilter = state
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = .blue, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.white.opacity(0.2))
                .foregroundColor(isSelected ? Color(red: 0.13, green: 0.05, blue: 0.3) : .white)
                .cornerRadius(20)
        }
    }
}

struct ChecklistContentView: View {
    @ObservedObject var checklistManager: ChecklistManager
    let selectedFilter: ChecklistItemState?
    
    var filteredItems: [ChecklistItem] {
        if let filter = selectedFilter {
            return checklistManager.items.filter { $0.state == filter }
        }
        return checklistManager.items
    }
    
    var groupedItems: [String: [ChecklistItem]] {
        Dictionary(grouping: filteredItems) { $0.category }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(groupedItems.keys.sorted()), id: \.self) { category in
                    CategorySectionView(
                        category: category,
                        items: groupedItems[category] ?? [],
                        checklistManager: checklistManager
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom)
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
    }
}

struct CategorySectionView: View {
    let category: String
    let items: [ChecklistItem]
    @ObservedObject var checklistManager: ChecklistManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                ForEach(items) { item in
                    ChecklistItemRow(item: item, checklistManager: checklistManager)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct ChecklistItemRow: View {
    let item: ChecklistItem
    @ObservedObject var checklistManager: ChecklistManager
    @State private var showingDetail = false
    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    
    var body: some View {
        ZStack {
            // Background indicators
            HStack {
                Spacer()
                
                // Swipe left indicator (packed)
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Packed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.trailing, 20)
                .opacity(offset < -20 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: offset)
                
                // Swipe right indicator (not needed)
                HStack {
                    Text("Not Needed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 20)
                .opacity(offset > 20 ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: offset)
            }
            
            // Main content
            HStack(spacing: 12) {
                // State Button
                Button(action: {
                    cycleItemState()
                }) {
                    Image(systemName: item.state.icon)
                        .font(.title2)
                        .foregroundColor(item.state == .packed ? .green : item.state == .notNeeded ? .gray : .white)
                }
                
                // Item Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(item.state == .notNeeded ? .white.opacity(0.6) : .white)
                        .strikethrough(item.state == .packed)
                    
                    Text(item.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Detail Button
                Button(action: { showingDetail = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isSwiping = true
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        isSwiping = false
                        let threshold: CGFloat = 60
                        
                        if value.translation.width < -threshold {
                            // Swipe left - toggle packed state
                            if item.state == .packed {
                                checklistManager.updateItemState(item, newState: .notPacked)
                            } else {
                                checklistManager.updateItemState(item, newState: .packed)
                            }
                        } else if value.translation.width > threshold {
                            // Swipe right - toggle not needed state
                            if item.state == .notNeeded {
                                checklistManager.updateItemState(item, newState: .notPacked)
                            } else {
                                checklistManager.updateItemState(item, newState: .notNeeded)
                            }
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
            )
            .sheet(isPresented: $showingDetail) {
                ItemDetailView(item: item, checklistManager: checklistManager)
            }
        }
    }
    
    private func cycleItemState() {
        let states: [ChecklistItemState] = [.notPacked, .packed, .notNeeded]
        if let currentIndex = states.firstIndex(of: item.state) {
            let nextIndex = (currentIndex + 1) % states.count
            checklistManager.updateItemState(item, newState: states[nextIndex])
        }
    }
}

struct ItemDetailView: View {
    let item: ChecklistItem
    @ObservedObject var checklistManager: ChecklistManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    Text(item.category)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    Text(item.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 16) {
                        ForEach(ChecklistItemState.allCases, id: \.self) { state in
                            Button(action: {
                                checklistManager.updateItemState(item, newState: state)
                            }) {
                                HStack {
                                    Image(systemName: state.icon)
                                    Text(state.rawValue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(item.state == state ? Color.white : Color.white.opacity(0.2))
                                .foregroundColor(item.state == state ? Color(red: 0.13, green: 0.05, blue: 0.3) : .white)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(red: 0.13, green: 0.05, blue: 0.3))
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct AddItemView: View {
    @ObservedObject var checklistManager: ChecklistManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var itemCategory = "Custom"
    @State private var itemDescription = ""
    
    let categories = ["Essential", "Camping", "Clothing", "Electronics", "Food & Drink", "Health & Safety", "Personal Care", "Optional", "Custom"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Item Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    TextField("Enter item name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Picker("Category", selection: $itemCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.vertical, 8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    TextField("Enter description", text: $itemDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.white)
                        .cornerRadius(8)
                        .lineLimit(3...6)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(red: 0.13, green: 0.05, blue: 0.3))
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !itemName.isEmpty {
                            checklistManager.addCustomItem(
                                name: itemName,
                                category: itemCategory,
                                description: itemDescription.isEmpty ? "Custom item" : itemDescription
                            )
                            dismiss()
                        }
                    }
                    .disabled(itemName.isEmpty)
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    ChecklistView()
} 