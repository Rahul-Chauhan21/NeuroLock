//
//  DeviceActivityManager.swift
//  NeuroLock
//
//  Created by Rahul Chauhan on 4/15/26.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    
    @Published var isAuthorized = false
    @Published var selection = FamilyActivitySelection() {
        didSet {
            FocusShared.saveSelection(selection)
        }
    }
    
    @Published var isSessionActive: Bool = false {
        didSet {
            FocusShared.setIsSessionActive(isSessionActive)
        }
    }
    
    @Published var escalationLevel: Int = 0 {
        didSet {
            FocusShared.setEscalationLevel(escalationLevel)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    
    private init() {
        self.isSessionActive = FocusShared.getIsSessionActive()
        self.escalationLevel = FocusShared.getEscalationLevel()
        self.selection = FocusShared.loadSelection()
        
        // Start a timer to sync state from extensions
        // In production, Darwin notifications are better, but this is robust for a prototype.
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.syncFromShared()
        }
    }
    
    private func syncFromShared() {
        let sharedLevel = FocusShared.getEscalationLevel()
        if sharedLevel != self.escalationLevel {
            DispatchQueue.main.async {
                self.escalationLevel = sharedLevel
            }
        }
        
        let sharedActive = FocusShared.getIsSessionActive()
        if sharedActive != self.isSessionActive {
            DispatchQueue.main.async {
                self.isSessionActive = sharedActive
            }
        }
    }
    
    @MainActor
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            self.isAuthorized = true
        } catch {
            print("Failed to authorize FamilyControls: \(error.localizedDescription)")
            self.isAuthorized = false
        }
    }
    
    func startFocusSession() {
        escalationLevel = 0
        isSessionActive = true
        FocusShared.applyShields(selection: selection)
    }
    
    func stopFocusSession() {
        isSessionActive = false
        escalationLevel = 0 // Reset level when stopped
        FocusShared.clearShields()
    }
}
