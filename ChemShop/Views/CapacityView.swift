//
//  CapacityView.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

struct CapacityView: View {
    @Query private var posts: [Post]
    @Query private var bookings: [CarBooking]
    let onBack: () -> Void
    
    // Вычисляем реальную загруженность на основе записей
    var postsWithCapacity: [Post] {
        let postNames = ["A", "B", "C", "D"]
        
        // Если есть данные постов, используем их
        if !posts.isEmpty {
            return posts
        }
        
        // Иначе создаем плейсхолдеры с реальной загруженностью
        return postNames.map { postName in
            let todayBookings = getTodayBookingsForPost(postName)
            let capacity = calculateCapacity(for: todayBookings)
            return Post(name: postName, capacity: capacity)
        }
    }
    
    private func getTodayBookingsForPost(_ postName: String) -> [CarBooking] {
        let calendar = Calendar.current
        let today = Date()
        return bookings.filter { booking in
            booking.post == postName && calendar.isDate(booking.time, inSameDayAs: today)
        }
    }
    
    private func calculateCapacity(for bookings: [CarBooking]) -> Int {
        // Простая логика: каждые 2 записи = 25% загруженности
        let capacity = min(bookings.count * 25, 100)
        return capacity
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с кнопкой назад
            HStack {
                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primaryText)
                }
                
                Image(systemName: "chart.bar")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                
                Text("Capacity")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.appBackground)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Контейнер для всех постов и графика
                    VStack(spacing: 0) {
                        // Заголовок в контейнере
                        Text("Post Occupancy (Today)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        ForEach(Array(postsWithCapacity.enumerated()), id: \.element.id) { index, post in
                            PostCapacityCard(post: post)
                            
                            // Разделитель между постами (кроме последнего)
                            if index < postsWithCapacity.count - 1 {
                                Rectangle()
                                    .fill(Color.cardBorder)
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Разделитель перед графиком
                        Rectangle()
                            .fill(Color.cardBorder)
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        
                        // График внутри того же контейнера
                        PostsStatisticsChart(posts: postsWithCapacity)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                    .background(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(16)
                    .padding()
                }
            }
            .background(Color.appBackground)
        }
    }
}

struct PostCapacityCard: View {
    let post: Post
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Post \(post.name)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text("\(post.capacity)%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            ProgressView(value: Double(post.capacity), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .capacitySliderColor))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                .frame(height: 6)
            
            HStack {
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                
                Text("\(100 - post.capacity)%")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var capacityColor: Color {
        switch post.capacity {
        case 0..<30:
            return .statusCompleted
        case 30..<70:
            return .statusWaiting
        default:
            return .statusInProgress
        }
    }
}

struct PostsStatisticsChart: View {
    let posts: [Post]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(posts.sorted(by: { $0.name < $1.name })) { post in
                VStack(spacing: 6) {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 30, height: max(4, CGFloat(post.capacity) * 0.8))
                        .cornerRadius(3)
                    
                    Text("Post \(post.name)")
                        .font(.caption2)
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .frame(height: 60)
    }
    
    private func postCapacityColor(_ capacity: Int) -> Color {
        switch capacity {
        case 0..<30:
            return .statusCompleted
        case 30..<70:
            return .statusWaiting
        default:
            return .statusInProgress
        }
    }
}

#Preview {
    CapacityView(onBack: {})
        .modelContainer(for: [CarBooking.self, InventoryItem.self, Post.self], inMemory: true)
}
