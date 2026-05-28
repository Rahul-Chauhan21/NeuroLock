//
//  ContentView.swift
//  NeuroLock
//
//  Created by Rahul Chauhan on 4/15/26.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var manager: DeviceActivityManager
    @State private var isPickerPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                
                // The "Annoyance Protocol" Overlay for Level 3
                if manager.escalationLevel >= 2 {
                    AnnoyanceProtocolOverlay()
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }
            .navigationTitle("NeuroLock")
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $manager.selection)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            if !manager.isAuthorized {
                authorizationNeededView
            } else {
                AppSelectionCard(selection: $manager.selection, isPickerPresented: $isPickerPresented)
                SessionStatusCard()
                Spacer()
            }
        }
        .padding()
    }
    
    private var authorizationNeededView: some View {
        ContentUnavailableView {
            Label("Screen Time Needed", systemImage: "lock.shield")
        } description: {
            Text("Please grant Screen Time permissions in Settings to allow NeuroLock to help you focus.")
        } actions: {
            Button("Check Permissions") {
                Task { await manager.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DeviceActivityManager.shared)
}
