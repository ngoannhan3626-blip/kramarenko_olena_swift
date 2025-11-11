//
//  Post.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import Foundation
import SwiftData

@Model
class Post {
    var id: UUID
    var name: String // A, B, C, D
    var capacity: Int // Процент загруженности 0-100
    
    init(name: String, capacity: Int) {
        self.id = UUID()
        self.name = name
        self.capacity = capacity
    }
}
