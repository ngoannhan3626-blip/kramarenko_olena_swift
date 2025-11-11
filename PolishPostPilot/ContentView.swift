//
//  ContentView.swift
//  ChemShop
//
//  Created by cybercrot on 26.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            HomeView()
        }
        .navigationBarHidden(true)
        .background(Color.appBackground)
    }
}

#Preview {
    ContentView()
}
