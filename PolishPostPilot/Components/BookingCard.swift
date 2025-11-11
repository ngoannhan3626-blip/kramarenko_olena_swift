//
//  BookingCard.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

struct BookingCard: View {
    let booking: CarBooking
    @State private var showingStatusEdit = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка автомобиля в контейнере
            Image(systemName: "car.fill")
                .font(.title2)
                .foregroundColor(.primaryText)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Тип услуги (заголовок)
                Text(booking.serviceType?.rawValue ?? "Other")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                // Пост и номер машины в темном прямоугольнике
                HStack(spacing: 8) {
                    Text("Post \(booking.post)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    Text(booking.carNumber)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .cornerRadius(6)
                
                // Время с иконкой часов
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondaryText)
                    
                    Text(formatTime(booking.time))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // Статус справа
            Text(booking.status.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor)
                .cornerRadius(6)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingStatusEdit) {
            BookingStatusEditView(booking: booking)
        }
        .onTapGesture {
            showingStatusEdit = true
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .waiting:
            return .statusWaiting
        case .inProgress:
            return .statusCompleted
        case .completed:
            return .statusInProgress
        }
    }
}

struct BookingStatusEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let booking: CarBooking
    @State private var selectedStatus: BookingStatus
    
    init(booking: CarBooking) {
        self.booking = booking
        self._selectedStatus = State(initialValue: booking.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Booking Information") {
                    HStack {
                        Text("Post:")
                        Spacer()
                        Text("Post \(booking.post)")
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Car Number:")
                        Spacer()
                        Text(booking.carNumber)
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Service:")
                        Spacer()
                        Text(booking.serviceType?.rawValue ?? "Other")
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Time:")
                        Spacer()
                        Text(formatTime(booking.time))
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Section("Change Status") {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(BookingStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Change Status")
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
                        saveStatus()
                    }
                    .foregroundColor(.primaryText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveStatus() {
        booking.status = selectedStatus
        try? modelContext.save()
        dismiss()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    BookingCard(booking: CarBooking(
        time: Date(),
        post: "A",
        carNumber: "A777AA",
        serviceName: "Мойка + полировка",
        serviceType: .expressWash,
        status: .waiting
    ))
    .padding()
    .background(Color.appBackground)
}
