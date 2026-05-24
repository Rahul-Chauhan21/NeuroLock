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
    
    // Annoyance Protocol State
    @State private var pledgeText: String = ""
    @State private var countdownRemaining = 0
    @State private var timer: Timer?
    
    let targetPledge = "I am choosing to break my focus and delay my goals for a temporary distraction."
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                
                // The "Annoyance Protocol" Overlay for Level 3
                if manager.escalationLevel >= 2 {
                    annoyanceProtocolOverlay
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
                appSelectionCard
                sessionStatusCard
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
    
    private var appSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. Focus Target")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: { isPickerPresented = true }) {
                HStack {
                    Image(systemName: "plus.app.fill")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(manager.selection.applicationTokens.isEmpty ? "Select Apps to Block" : "\(manager.selection.applicationTokens.count) Apps Selected")
                            .font(.body.weight(.semibold))
                        Text("Choose the apps that distract you most.")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(16)
            }
        }
    }
    
    private var sessionStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. Focus Session")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Button(action: toggleSession) {
                    Text(manager.isSessionActive ? "Stop Focus Session" : "Start Focus Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(manager.isSessionActive ? Color.red : Color.green)
                        .cornerRadius(16)
                        .shadow(color: (manager.isSessionActive ? Color.red : Color.green).opacity(0.3), radius: 8, y: 4)
                }
                
                if manager.isSessionActive {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Escalation Level: \(manager.escalationLevel)")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int((Double(manager.escalationLevel) / 2.0) * 100))%")
                                .font(.caption.bold())
                        }
                        
                        ProgressView(value: Double(manager.escalationLevel), total: 2.0)
                            .tint(manager.escalationLevel == 0 ? .green : (manager.escalationLevel == 1 ? .orange : .red))
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var annoyanceProtocolOverlay: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                        .symbolEffect(.bounce, value: manager.escalationLevel)
                    
                    Text("Manual Override Required")
                        .font(.title.bold())
                    
                    Text("Your impulsive brain is in control. You must complete this task to prove you are making a conscious choice.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Type the following exactly:")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    
                    Text(targetPledge)
                        .font(.body.italic())
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.2), lineWidth: 1))
                    
                    TextField("Start typing here...", text: $pledgeText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
                .padding()
                
                VStack(spacing: 16) {
                    if countdownRemaining > 0 {
                        Text("Override available in \(countdownRemaining)s")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: unlockSession) {
                        Text("Confirm Override")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isPledgeCorrect && countdownRemaining == 0 ? Color.red : Color.gray)
                            .cornerRadius(16)
                    }
                    .disabled(!isPledgeCorrect || countdownRemaining > 0)
                    
                    Button("I'll get back to work") {
                        manager.escalationLevel = 1
                    }
                    .font(.subheadline.bold())
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private var isPledgeCorrect: Bool {
        pledgeText.trimmingCharacters(in: .whitespacesAndNewlines) == targetPledge
    }
    
    private func startCountdown() {
        countdownRemaining = 60 // 60 second forced wait
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdownRemaining > 0 {
                countdownRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func toggleSession() {
        if manager.isSessionActive {
            // Only allow stopping directly if level is 0
            if manager.escalationLevel == 0 {
                manager.stopFocusSession()
            } else {
                // Elevate escalation level to 2 to trigger the Annoyance Protocol overlay
                manager.escalationLevel = 2
            }
        } else {
            manager.startFocusSession()
        }
    }
    
    private func unlockSession() {
        manager.stopFocusSession()
        pledgeText = "" // Reset
    }
}

#Preview {
    ContentView()
        .environmentObject(DeviceActivityManager.shared)
}
