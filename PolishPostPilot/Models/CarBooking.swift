//
//  CarBooking.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import Foundation
import SwiftData

@Model
class CarBooking {
    var id: UUID
    var time: Date
    var post: String // A, B, C, D
    var carNumber: String
    var serviceName: String? // Название услуги (опциональное для совместимости)
    var serviceType: ServiceType? // Тип услуги для группировки (опциональное для совместимости)
    var status: BookingStatus
    
    init(time: Date, post: String, carNumber: String, serviceName: String? = nil, serviceType: ServiceType? = nil, status: BookingStatus) {
        self.id = UUID()
        self.time = time
        self.post = post
        self.carNumber = carNumber
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.status = status
    }
}

enum BookingStatus: String, CaseIterable, Codable {
    case waiting = "Waiting"
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var displayName: String {
        switch self {
        case .waiting:
            return "Waiting"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        }
    }
}

enum ServiceType: String, CaseIterable, Codable {
    case expressWash = "Express Wash"
    case polish2Step = "2-Step Polish"
    case ceramic1Layer = "1-Layer Ceramic"
    case interiorCleaning = "Interior Cleaning"
    case fullService = "Full Service"
    case other = "Other"
}
