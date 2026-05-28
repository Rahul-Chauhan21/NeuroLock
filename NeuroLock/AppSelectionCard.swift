//
//  AppSelectionCard.swift
//  NeuroLock
//
//  Created by Antigravity on 5/28/26.
//

import SwiftUI
import FamilyControls

struct AppSelectionCard: View {
    @Binding var selection: FamilyActivitySelection
    @Binding var isPickerPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. Focus Target")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: { isPickerPresented = true }) {
                HStack {
                    Image(systemName: "plus.app.fill")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(selection.applicationTokens.isEmpty ? "Select Apps to Block" : "\(selection.applicationTokens.count) Apps Selected")
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
}
