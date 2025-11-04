//
//  AppColors.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI

extension Color {
    static let appBackground = Color(hex: "#020617")
    static let cardBackground = Color.white.opacity(0.03)
    static let cardBorder = Color.white.opacity(0.15)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    
    // Статусы
    static let statusWaiting = Color(hex: "#FFF4C6")
    static let statusInProgress = Color(hex: "#D1FAE5")
    static let statusCompleted = Color(hex: "#34C759")
    
    // Цвета для подсказок в фильтрах
    static let filterBadgeBackground = Color(hex: "#3F3123")
    static let filterBadgeText = Color(hex: "#E8BD30")
    
    // Цвет для слайдеров загруженности
    static let capacitySliderColor = Color(hex: "#23334D")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension BookingStatus {
    var color: Color {
        switch self {
        case .waiting:
            return .statusWaiting
        case .inProgress:
            return .statusInProgress
        case .completed:
            return .statusCompleted
        }
    }
}
