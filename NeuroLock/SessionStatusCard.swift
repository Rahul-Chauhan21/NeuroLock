//
//  SessionStatusCard.swift
//  NeuroLock
//
//  Created by Antigravity on 5/28/26.
//

import SwiftUI

struct SessionStatusCard: View {
    @EnvironmentObject var manager: DeviceActivityManager
    
    var body: some View {
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
}
