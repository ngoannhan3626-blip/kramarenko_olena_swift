import SwiftUI
import SwiftData

struct InventoryUsageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let item: InventoryItem
    
    @State private var quantityToUse = ""
    @State private var selectedPost = "A"
    @State private var selectedDate = Date()
    @State private var notes = ""
    
    let posts = ["A", "B", "C", "D"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Usage Information") {
                    HStack {
                        Text("Item:")
                        Spacer()
                        Text(item.name)
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Available:")
                        Spacer()
                        Text("\(item.quantity) pcs")
                            .foregroundColor(.secondaryText)
                    }
                    
                    TextField("Quantity to write off", text: $quantityToUse)
                        .keyboardType(.numberPad)
                    
                    Picker("Post", selection: $selectedPost) {
                        ForEach(posts, id: \.self) { post in
                            Text("Post \(post)").tag(post)
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    TextField("Notes (optional)", text: $notes)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Write Off Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Write Off") {
                        recordUsage()
                    }
                    .disabled(quantityToUse.isEmpty || Int(quantityToUse) == nil || Int(quantityToUse)! > item.quantity)
                    .foregroundColor(.primaryText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func recordUsage() {
        guard let quantity = Int(quantityToUse), quantity > 0, quantity <= item.quantity else { return }
        
        // Создаем запись о списании
        let usage = InventoryUsage(
            itemId: item.id,
            itemName: item.name,
            itemType: item.type,
            quantityUsed: quantity,
            date: selectedDate,
            post: selectedPost,
            bookingId: nil
        )
        
        // Обновляем количество товара
        item.quantity -= quantity
        
        // Сохраняем изменения
        modelContext.insert(usage)
        try? modelContext.save()
        
        dismiss()
    }
}
