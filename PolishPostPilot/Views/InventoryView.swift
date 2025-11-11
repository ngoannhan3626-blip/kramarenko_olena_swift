//
//  InventoryView.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

enum InventoryFilter: String, CaseIterable {
    case all = "All"
    case low = "Low"
    case critical = "Critical"
}

struct InventoryView: View {
    @Query private var inventoryItems: [InventoryItem]
    @State private var showingAddItem = false
    @State private var selectedFilter: InventoryFilter = .all
    @State private var selectedType: InventoryType? = nil
    let onBack: () -> Void
    
    var filteredItems: [InventoryItem] {
        var items = inventoryItems
        
        // Фильтр по количеству
        switch selectedFilter {
        case .all:
            break
        case .low:
            items = items.filter { $0.quantity < 10 && $0.quantity >= 5 }
        case .critical:
            items = items.filter { $0.quantity < 5 }
        }
        
        // Фильтр по типу
        if let selectedType = selectedType {
            items = items.filter { $0.type == selectedType }
        }
        
        return items.sorted { $0.name < $1.name }
    }
    
    var lowCount: Int {
        inventoryItems.filter { $0.quantity < 10 && $0.quantity >= 5 }.count
    }
    
    var criticalCount: Int {
        inventoryItems.filter { $0.quantity < 5 }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с кнопкой назад и плюс
            HStack {
                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primaryText)
                }
                
                Image(systemName: "shippingbox")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                
                Text("Inventory")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
                
                // Фильтры по количеству
                HStack(spacing: 12) {
                    InventoryFilterButton(
                        title: "All",
                        isSelected: selectedFilter == .all,
                        action: { selectedFilter = .all }
                    )
                    
                    InventoryFilterButton(
                        title: "Low",
                        isSelected: selectedFilter == .low,
                        badge: lowCount > 0 ? lowCount : nil,
                        action: { selectedFilter = .low }
                    )
                    
                    InventoryFilterButton(
                        title: "Critical",
                        isSelected: selectedFilter == .critical,
                        badge: criticalCount > 0 ? criticalCount : nil,
                        action: { selectedFilter = .critical }
                    )
                    
                    Spacer()
                    
                    Button("All Categories") {
                        selectedType = nil
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedType == nil ? .white : .secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedType == nil ? Color.white : Color.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Фильтры по типам
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(InventoryType.allCases, id: \.self) { type in
                            InventoryTypeButton(
                                title: type.rawValue,
                                isSelected: selectedType == type,
                                action: { 
                                    selectedType = selectedType == type ? nil : type
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Карточки статистики
                HStack(spacing: 12) {
                    // Карточка позиций
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Items")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        Text("\(inventoryItems.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(12)
                    
                    // Карточка низких остатков
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(.statusWaiting)
                            
                            Text("Low")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primaryText)
                        }
                        
                        Text("\(lowCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Новый контейнер между роу чартом и списком остатков
                VStack(alignment: .leading, spacing: 8) {
                    Text("Statistics by Type")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                        .padding(.horizontal)
                    
                    InventoryTypeChart(items: inventoryItems)
                        .frame(height: 80)
                        .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Список товаров в контейнере
                ScrollView {
                    VStack(spacing: 0) {
                        // Заголовок
                        HStack(spacing: 8) {
                            Text("Stock List")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        if filteredItems.isEmpty {
                            Text("No items found")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        } else {
                            // Список товаров с разделителями
                            LazyVStack(spacing: 0) {
                                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                    InventoryItemCard(item: item)
                                    
                                    // Разделитель между товарами (кроме последнего)
                                    if index < filteredItems.count - 1 {
                                        Rectangle()
                                            .fill(Color.cardBorder)
                                            .frame(height: 1)
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .background(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .background(Color.appBackground)
            }
            .background(Color.appBackground)
            .sheet(isPresented: $showingAddItem) {
                AddInventoryItemView()
            }
        }
    }

struct InventoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let badge: Int?
    let action: () -> Void
    
    init(title: String, isSelected: Bool, badge: Int? = nil, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.badge = badge
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .black : .secondaryText)
                    .lineLimit(1)
                
                if let badge = badge {
                    Text("\(badge)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.filterBadgeText)
                        .frame(width: 14, height: 14)
                        .background(Color.filterBadgeBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}

struct InventoryTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.white : Color.cardBorder, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

struct InventoryTypeChart: View {
    let items: [InventoryItem]
    @Query private var usageRecords: [InventoryUsage]
    
    var typeData: [(InventoryType, Int)] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        // Получаем записи о списаниях за последнюю неделю
        let weeklyUsage = usageRecords.filter { usage in
            usage.date >= weekAgo && usage.date <= now
        }
        
        let grouped = Dictionary(grouping: weeklyUsage) { $0.itemType }
        return InventoryType.allCases.compactMap { type in
            guard let usages = grouped[type], !usages.isEmpty else { return nil }
            let totalUsage = usages.reduce(0) { $0 + $1.quantityUsed }
            return (type, totalUsage)
        }
    }
    
    var maxValue: Int {
        typeData.map { $0.1 }.max() ?? 1
    }
    
    var body: some View {
        if typeData.isEmpty {
            // Плейсхолдер когда нет данных
            VStack {
                Text("No expenses")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            .frame(height: 80)
        } else {
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(typeData, id: \.0) { type, usage in
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(
                                width: 30,
                                height: min(60, max(4, CGFloat(usage) / CGFloat(maxValue) * 50))
                            )
                            .cornerRadius(2)
                        
                        Text(type.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                }
            }
            .frame(height: 80)
        }
    }
}

struct AddInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let existingItem: InventoryItem?
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var selectedType: InventoryType = .shampoo
    
    init(existingItem: InventoryItem? = nil) {
        self.existingItem = existingItem
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Information") {
                    TextField("Name", text: $name)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(InventoryType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle(existingItem != nil ? "Replenish Item" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || quantity.isEmpty)
                    .foregroundColor(.primaryText)
                }
            }
            .onAppear {
                if let item = existingItem {
                    name = item.name
                    quantity = String(item.quantity)
                    selectedType = item.type
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveItem() {
        guard let quantityInt = Int(quantity) else { return }
        
        if let existingItem = existingItem {
            // Обновляем существующий товар
            existingItem.name = name
            existingItem.quantity = quantityInt
            existingItem.type = selectedType
        } else {
            // Создаем новый товар
            let newItem = InventoryItem(
                name: name,
                quantity: quantityInt,
                type: selectedType
            )
            modelContext.insert(newItem)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

struct InventoryItemCard: View {
    let item: InventoryItem
    @State private var showingUsageSheet = false
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Верхняя строка: название и категория
            HStack {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text(item.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
            }
            
            // Информация о количестве
            HStack(spacing: 16) {
                Text("In stock: \(item.quantity) pcs")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Text("Min: 1 pc")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            // Кнопки внизу
            HStack(spacing: 12) {
                Button("Add") {
                    showingAddSheet = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green)
                .cornerRadius(8)
                
                Button("Write Off") {
                    showingUsageSheet = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
                
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingUsageSheet) {
            InventoryUsageView(item: item)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddInventoryItemView(existingItem: item)
        }
    }
}

#Preview {
    InventoryView(onBack: {})
        .modelContainer(for: [CarBooking.self, InventoryItem.self, Post.self], inMemory: true)
}
