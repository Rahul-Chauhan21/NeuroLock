//
//  AnnoyanceProtocolOverlay.swift
//  NeuroLock
//
//  Created by Antigravity on 5/28/26.
//

import SwiftUI

struct AnnoyanceProtocolOverlay: View {
    @EnvironmentObject var manager: DeviceActivityManager
    
    @State private var pledgeText: String = ""
    @State private var countdownRemaining = 0
    @State private var countdownTask: Task<Void, Never>? = nil
    
    let targetPledge = "I am choosing to break my focus and delay my goals for a temporary distraction."
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header (Static - never re-renders from keystrokes or timer)
                HeaderSection(escalationLevel: manager.escalationLevel)
                
                // Typing Area (Re-renders on keystroke, isolated from countdown and headers)
                PledgeInputSection(
                    targetPledge: targetPledge,
                    pledgeText: $pledgeText
                )
                
                // Action Buttons & Countdown (Re-renders once per second, isolated from headers)
                ActionSection(
                    countdownRemaining: countdownRemaining,
                    isPledgeCorrect: isPledgeCorrect,
                    onConfirm: unlockSession,
                    onCancel: { manager.escalationLevel = 1 }
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            countdownTask?.cancel()
        }
    }
    
    private var isPledgeCorrect: Bool {
        pledgeText.trimmingCharacters(in: .whitespacesAndNewlines) == targetPledge
    }
    
    private func startCountdown() {
        countdownRemaining = 60
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            while countdownRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                countdownRemaining -= 1
            }
        }
    }
    
    private func unlockSession() {
        manager.stopFocusSession()
        pledgeText = ""
    }
}

// MARK: - Subviews for Isolated Rendering

private struct HeaderSection: View {
    let escalationLevel: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 64))
                .foregroundColor(.red)
                .symbolEffect(.bounce, value: escalationLevel)
            
            Text("Manual Override Required")
                .font(.title.bold())
            
            Text("Your impulsive brain is in control. You must complete this task to prove you are making a conscious choice.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.top, 40)
    }
}

private struct PledgeInputSection: View {
    let targetPledge: String
    @Binding var pledgeText: String
    
    var body: some View {
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
    }
}

private struct ActionSection: View {
    let countdownRemaining: Int
    let isPledgeCorrect: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            if countdownRemaining > 0 {
                Text("Override available in \(countdownRemaining)s")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onConfirm) {
                Text("Confirm Override")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isPledgeCorrect && countdownRemaining == 0 ? Color.red : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(!isPledgeCorrect || countdownRemaining > 0)
            
            Button("I'll get back to work", action: onCancel)
                .font(.subheadline.bold())
        }
        .padding()
    }
}
