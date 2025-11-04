//
//  BookingsScreen.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

struct BookingsScreen: View {
    @Query private var bookings: [CarBooking]
    @State private var selectedTimeFilter: TimeFilter = .day
    @State private var selectedPostFilter: PostFilter = .all
    @State private var showingAddBooking = false
    let onBack: () -> Void
    
    var filteredBookings: [CarBooking] {
        var filtered = bookings
        
        // Фильтр по времени
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFilter {
        case .day:
            filtered = filtered.filter { booking in
                calendar.isDate(booking.time, inSameDayAs: now)
            }
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            filtered = filtered.filter { booking in
                booking.time >= weekAgo
            }
        }
        
        // Фильтр по постам
        switch selectedPostFilter {
        case .all:
            break
        case .postA, .postB, .postC, .postD:
            let postLetter = selectedPostFilter.rawValue
            filtered = filtered.filter { booking in
                booking.post == postLetter
            }
        }
        
        return filtered.sorted { $0.time < $1.time }
    }
    
    var hourlyStatistics: [Int] {
        var hours = Array(repeating: 0, count: 12) // 12 столбцов вместо 24
        
        for booking in filteredBookings {
            let hour = Calendar.current.component(.hour, from: booking.time)
            // Группируем по 2 часа: 0-1, 2-3, 4-5, и т.д.
            let groupIndex = hour / 2
            if groupIndex < 12 {
                hours[groupIndex] += 1
            }
        }
        
        return hours
    }
    
    var dailyBookings: [(Date, [CarBooking])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredBookings) { booking in
            calendar.startOfDay(for: booking.time)
        }
        
        let sortedDates = grouped.keys.sorted()
        return sortedDates.compactMap { date in
            guard let bookings = grouped[date], !bookings.isEmpty else { return nil }
            return (date, bookings.sorted { $0.time < $1.time })
        }
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
                
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                
                Text("Bookings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    showingAddBooking = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
                
                // Фильтры времени и постов
                VStack(spacing: 8) {
                    // Фильтры времени и постов
                    HStack(spacing: 8) {
                        // Фильтры времени - сегментированный контрол
                        HStack(spacing: 0) {
                            TimeFilterButton(
                                title: "Day",
                                isSelected: selectedTimeFilter == .day,
                                action: { selectedTimeFilter = .day }
                            )
                            
                            TimeFilterButton(
                                title: "Week",
                                isSelected: selectedTimeFilter == .week,
                                action: { selectedTimeFilter = .week }
                            )
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Фильтры постов - компактные кнопки
                        HStack(spacing: 6) {
                            PostFilterButton(
                                title: "All",
                                isSelected: selectedPostFilter == .all,
                                action: { selectedPostFilter = .all }
                            )
                            
                            PostFilterButton(
                                title: "Post\nA",
                                isSelected: selectedPostFilter == .postA,
                                action: { selectedPostFilter = .postA }
                            )
                            
                            PostFilterButton(
                                title: "Post\nB",
                                isSelected: selectedPostFilter == .postB,
                                action: { selectedPostFilter = .postB }
                            )
                            
                            PostFilterButton(
                                title: "Post\nC",
                                isSelected: selectedPostFilter == .postC,
                                action: { selectedPostFilter = .postC }
                            )
                            
                            PostFilterButton(
                                title: "Post\nD",
                                isSelected: selectedPostFilter == .postD,
                                action: { selectedPostFilter = .postD }
                            )
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                // Разделительная линия
                Rectangle()
                    .fill(Color.cardBorder)
                    .frame(height: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                
                // Статистика загруженности по часам (отдельно)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hourly Load")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    if hourlyStatistics.allSatisfy({ $0 == 0 }) {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 60)
                    } else {
                        HourlyStatisticsChart(data: hourlyStatistics)
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Список записей по дням
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(Array(dailyBookings.enumerated()), id: \.element.0) { index, dayData in
                            let (date, bookings) = dayData
                            
                            // Контейнер для записей одного дня
                            VStack(spacing: 0) {
                                // Заголовок дня с иконкой календаря
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundColor(.primaryText)
                                    
                                    Text(formatDayTitle(date))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primaryText)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                // Список записей с разделителями
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(bookings.enumerated()), id: \.element.id) { bookingIndex, booking in
                                        BookingCard(booking: booking)
                                        
                                        // Разделитель между записями (кроме последней)
                                        if bookingIndex < bookings.count - 1 {
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
                }
                .background(Color.appBackground)
            }
            .background(Color.appBackground)
            .sheet(isPresented: $showingAddBooking) {
                AddBookingView()
            }
        }
    }
    
    private func formatDayTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? today) {
            return "Yesterday"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today) ?? today) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM"
            formatter.locale = Locale(identifier: "en_US")
            return formatter.string(from: date)
        }
    }



struct TimeFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(isSelected ? Color.gray.opacity(0.4) : Color.clear)
        }
    }
}

struct PostFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .primaryText : .secondaryText)
                .multilineTextAlignment(.center)
                .frame(minWidth: 30,maxWidth: 80, minHeight: 45)
                .padding(.horizontal, 8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.primaryText : Color.cardBorder, lineWidth: isSelected ? 2 : 1)
                )
                .cornerRadius(6)
        }
    }
}

struct HourlyStatisticsChart: View {
    let data: [Int]
    
    var maxValue: Int {
        data.max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Столбцы графика
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<12, id: \.self) { groupIndex in
                    Rectangle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 20, height: max(4, CGFloat(data[groupIndex]) / CGFloat(maxValue) * 40))
                        .cornerRadius(2)
                }
            }
            
            // Подписи времени (только 5 штук)
            HStack {
                Spacer()
                Text("10:00")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                Text("12:00")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                Text("14:00")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                Text("16:00")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                Text("18:00")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                
                Spacer()
            }
        }
        .frame(height: 60)
    }
}

enum TimeFilter: CaseIterable {
    case day, week
}

enum PostFilter: String, CaseIterable {
    case all = "All"
    case postA = "A"
    case postB = "B"
    case postC = "C"
    case postD = "D"
}

struct AddBookingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTime = Date()
    @State private var selectedPost: PostFilter = .postA
    @State private var carNumber = ""
    @State private var serviceName = ""
    @State private var selectedServiceType: ServiceType = .expressWash
    @State private var selectedStatus: BookingStatus = .waiting
    
    var body: some View {
        NavigationView {
            Form {
                Section("Booking Information") {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Post", selection: $selectedPost) {
                        ForEach(PostFilter.allCases.filter { $0 != .all }, id: \.self) { post in
                            Text("Post \(post.rawValue)").tag(post)
                        }
                    }
                    
                    TextField("Car Number", text: $carNumber)
                    
                    Picker("Service Type", selection: $selectedServiceType) {
                        ForEach(ServiceType.allCases, id: \.self) { serviceType in
                            Text(serviceType.rawValue).tag(serviceType)
                        }
                    }
                    
                    TextField("Service Name (optional)", text: $serviceName)
                    
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(BookingStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Add Booking")
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
                        saveBooking()
                    }
                    .disabled(carNumber.isEmpty)
                    .foregroundColor(.primaryText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveBooking() {
        let newBooking = CarBooking(
            time: selectedTime,
            post: selectedPost.rawValue,
            carNumber: carNumber,
            serviceName: serviceName.isEmpty ? nil : serviceName,
            serviceType: selectedServiceType,
            status: selectedStatus
        )
        
        modelContext.insert(newBooking)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    BookingsScreen(onBack: {})
        .modelContainer(for: [CarBooking.self, InventoryItem.self, Post.self], inMemory: true)
}
