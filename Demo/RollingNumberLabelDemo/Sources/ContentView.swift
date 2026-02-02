//
//  ContentView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Basic Demo") {
                    BasicDemoView()
                }

                NavigationLink("Currency Demo") {
                    CurrencyDemoView()
                }

                NavigationLink("Customization Demo") {
                    CustomizationDemoView()
                }

                NavigationLink("Stress Test") {
                    StressTestDemoView()
                }
            }
            .navigationTitle("RollingNumberLabel")
        }
    }
}

#Preview {
    ContentView()
}
