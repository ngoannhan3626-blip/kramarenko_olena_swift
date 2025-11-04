//
//  InventoryItem.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import Foundation
import SwiftData

@Model
class InventoryItem {
    var id: UUID
    var name: String
    var quantity: Int
    var type: InventoryType
    
    init(name: String, quantity: Int, type: InventoryType) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.type = type
    }
}

enum InventoryType: String, CaseIterable, Codable {
    case shampoo = "Shampoo"
    case polish = "Polish"
    case towels = "Towels"
    case conditioner = "Conditioner"
    
    var icon: String {
        switch self {
        case .shampoo:
            return "drop.fill"
        case .polish:
            return "sparkles"
        case .towels:
            return "rectangle.stack.fill"
        case .conditioner:
            return "drop.circle.fill"
        }
    }
}
