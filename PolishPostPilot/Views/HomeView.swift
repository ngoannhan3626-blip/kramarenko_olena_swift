//
//  HomeView.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

enum TabSelection {
    case home, capacity, bookings, inventory
}

struct HomeView: View {
    @Query private var bookings: [CarBooking]
    @Query private var inventoryItems: [InventoryItem]
    @Query private var posts: [Post]
    @State private var showingAddBooking = false
    @State private var showingExport = false
    @State private var showingAddInventory = false
    @State private var selectedItem: InventoryItem?
    @State private var selectedTab: TabSelection = .home
    @Environment(\.modelContext) private var modelContext
    
    var todayBookings: [CarBooking] {
        let calendar = Calendar.current
        let today = Date()
        return bookings.filter { booking in
            calendar.isDate(booking.time, inSameDayAs: today)
        }.sorted { $0.time < $1.time }
    }
    
    var criticalInventoryItems: [InventoryItem] {
        // Предполагаем, что критично низкие остатки - это товары с количеством меньше 5
        return inventoryItems.filter { $0.quantity < 5 }
    }
    
    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                homeContent
            case .capacity:
                CapacityView(onBack: { selectedTab = .home })
            case .bookings:
                BookingsScreen(onBack: { selectedTab = .home })
            case .inventory:
                InventoryView(onBack: { selectedTab = .home })
            }
        }
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button("New") {
                        showingAddBooking = true
                    }
                    .foregroundColor(.primaryText)
                    
                    Button("Export") {
                        showingExport = true
                    }
                    .foregroundColor(.primaryText)
                }
            }
        }
        .sheet(isPresented: $showingAddBooking) {
            AddBookingView()
        }
        .sheet(isPresented: $showingExport) {
            ExportView()
        }
        .sheet(isPresented: $showingAddInventory) {
            if let item = selectedItem {
                AddInventoryItemView(existingItem: item)
            }
        }
        .onChange(of: showingAddInventory) { _, newValue in
            if !newValue {
                selectedItem = nil
            }
        }
        .onAppear {
            resetAllData()
        }
    }
    
    private var homeContent: some View {
        VStack(spacing: 0) {
            // Основной контент с прокруткой
            ScrollView {
                VStack(spacing: 24) {
                    // Название экрана и дата
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DetailFlow")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(formatDate(Date()))
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Секция сегодняшних записей в едином контейнере
                    VStack(spacing: 0) {
                        // Заголовок с иконкой часов
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.title2)
                                .foregroundColor(.primaryText)
                            
                            Text("Today's Bookings")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        if todayBookings.isEmpty {
                            Text("No bookings for today")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        } else {
                            // Список записей с разделителями
                            LazyVStack(spacing: 0) {
                                ForEach(Array(todayBookings.enumerated()), id: \.element.id) { index, booking in
                                    BookingCard(booking: booking)
                                    
                                    // Разделитель между записями (кроме последней)
                                    if index < todayBookings.count - 1 {
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
                    
                    // Секция критично низких остатков в едином контейнере
                    if !criticalInventoryItems.isEmpty {
                        VStack(spacing: 0) {
                            // Заголовок с иконкой предупреждения
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundColor(.statusWaiting)
                                
                                Text("Critical Stock")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // Список товаров с разделителями
                            LazyVStack(spacing: 0) {
                                ForEach(Array(criticalInventoryItems.enumerated()), id: \.element.id) { index, item in
                                    CriticalInventoryRow(item: item) {
                                        showingAddInventory = true
                                        selectedItem = item
                                    }
                                    
                                    // Разделитель между товарами (кроме последнего)
                                    if index < criticalInventoryItems.count - 1 {
                                        Rectangle()
                                            .fill(Color.cardBorder)
                                            .frame(height: 1)
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        .background(Color.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cardBorder, lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                }
                .padding()
                .padding(.bottom, 20) // Отступ снизу для кнопок навигации
            }
            
            // Фиксированные кнопки навигации внизу экрана
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.cardBorder)
                    .frame(height: 1)
                
                HStack(spacing: 0) {
                    Button(action: {
                        selectedTab = .capacity
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(.primaryText)
                            Text("Capacity")
                                .font(.caption)
                                .foregroundColor(.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Rectangle()
                        .fill(Color.cardBorder)
                        .frame(width: 1)
                    
                    Button(action: {
                        selectedTab = .bookings
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                                .foregroundColor(.primaryText)
                            Text("Bookings")
                                .font(.caption)
                                .foregroundColor(.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Rectangle()
                        .fill(Color.cardBorder)
                        .frame(width: 1)
                    
                    Button(action: {
                        selectedTab = .inventory
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "shippingbox.fill")
                                .font(.title2)
                                .foregroundColor(.primaryText)
                            Text("Inventory")
                                .font(.caption)
                                .foregroundColor(.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 70)
                .background(Color.cardBackground)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .cornerRadius(12)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func resetAllData() {
        // Удаляем все записи
        // for booking in bookings {
        //     modelContext.delete(booking)
        // }
        
        // Удаляем все товары на складе
        // for item in inventoryItems {
        //     modelContext.delete(item)
        // }
        
        // Удаляем все посты
        // for post in posts {
        //     modelContext.delete(post)
        // }
        
        // Удаляем все записи о списании
        // let usageRecords = try? modelContext.fetch(FetchDescriptor<InventoryUsage>())
        // for usage in usageRecords ?? [] {
        //     modelContext.delete(usage)
        // }
        
        // Сохраняем изменения
        // try? modelContext.save()
        
        // print("All application data has been cleared")
    }
}

struct CriticalInventoryRow: View {
    let item: InventoryItem
    let onReplenish: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка товара в контейнере
            Image(systemName: item.type.icon)
                .font(.title2)
                .foregroundColor(.primaryText)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Название товара (заголовок)
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                // Информация о количестве
                Text("In stock: \(item.quantity) pcs • Min: 5 pcs")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            // Кнопка пополнить
            Button("Replenish") {
                onReplenish()
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red)
            .cornerRadius(6)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export function will be implemented")
                    .foregroundColor(.primaryText)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [CarBooking.self, InventoryItem.self, Post.self], inMemory: true)
}
