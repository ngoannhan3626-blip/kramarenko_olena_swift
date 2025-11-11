//
//  InventoryItemRow.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI
import SwiftData

struct InventoryItemRow: View {
    let item: InventoryItem
    @State private var showingUsageSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.icon)
                .font(.title2)
                .foregroundColor(.primaryText)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                
                Text("\(item.quantity) pcs")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(item.quantity)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Button("Write Off") {
                    showingUsageSheet = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue)
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .cornerRadius(12)
        .sheet(isPresented: $showingUsageSheet) {
            InventoryUsageView(item: item)
        }
    }
}

#Preview {
    InventoryItemRow(item: InventoryItem(
        name: "Шампунь для мойки",
        quantity: 15,
        type: .shampoo
    ))
    .padding()
    .background(Color.appBackground)
}
