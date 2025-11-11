import Foundation
import SwiftData

@Model
class InventoryUsage {
    var id: UUID
    var itemId: UUID
    var itemName: String
    var itemType: InventoryType
    var quantityUsed: Int
    var date: Date
    var post: String? // Пост, где был использован расходник
    var bookingId: UUID? // Связь с записью о машине
    
    init(itemId: UUID, itemName: String, itemType: InventoryType, quantityUsed: Int, date: Date, post: String? = nil, bookingId: UUID? = nil) {
        self.id = UUID()
        self.itemId = itemId
        self.itemName = itemName
        self.itemType = itemType
        self.quantityUsed = quantityUsed
        self.date = date
        self.post = post
        self.bookingId = bookingId
    }
}
