//
//  dapperApp.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 5/25/24.
//

import SwiftUI

@main
struct dapperApp: App {
    
    @StateObject var userLogIn = UserLogIn()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userLogIn)
        }
    }
}
