//
//  NeuroLockApp.swift
//  NeuroLock
//
//  Created by Rahul Chauhan on 4/15/26.
//

import SwiftUI

@main
struct NeuroLockApp: App {
    @StateObject var deviceActivityManager = DeviceActivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceActivityManager)
                .task {
                    await deviceActivityManager.requestAuthorization()
                }
        }
    }
}
