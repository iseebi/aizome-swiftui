//
//  AizomeExampleApp.swift
//  AizomeExample
//
//  Created by Nobuhiro Ito on 2025/04/10.
//

import SwiftUI
import Aizome

@main
struct AizomeExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        Aizome.defineDefaultStyles([
            "red": BasicStringStyle(color: .red),
            "blue": BasicStringStyle(color: .blue),
            "green": BasicStringStyle(color: .green),
            "bold12": BasicStringStyle(font: .system(size: 12, weight: .bold)),
        ])
    }
}
