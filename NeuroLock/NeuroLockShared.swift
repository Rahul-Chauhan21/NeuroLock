//
//  NeuroLockShared.swift
//  NeuroLock
//
//  Created by Rahul Chauhan on 4/15/26.
//

import Foundation
import ManagedSettings
import FamilyControls

public enum FocusShared {
    public static let appGroupName = "group.com.rc.NeuroLock.shared"
    public static let escalationKey = "EscalationLevel"
    public static let sessionKey = "IsSessionActive"
    public static let selectionKey = "SelectedApps"
    
    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupName)
    }
    
    public static func getEscalationLevel() -> Int {
        sharedDefaults?.integer(forKey: escalationKey) ?? 0
    }
    
    public static func setEscalationLevel(_ level: Int) {
        sharedDefaults?.set(level, forKey: escalationKey)
    }
    
    public static func getIsSessionActive() -> Bool {
        sharedDefaults?.bool(forKey: sessionKey) ?? false
    }
    
    public static func setIsSessionActive(_ isActive: Bool) {
        sharedDefaults?.set(isActive, forKey: sessionKey)
    }
    
    public static func loadSelection() -> FamilyActivitySelection {
        guard let data = sharedDefaults?.data(forKey: selectionKey) else {
            return FamilyActivitySelection()
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode(FamilyActivitySelection.self, from: data)) ?? FamilyActivitySelection()
    }
    
    public static func saveSelection(_ selection: FamilyActivitySelection) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(selection) {
            sharedDefaults?.set(encoded, forKey: selectionKey)
        }
    }
    
    public static func applyShields(selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore()
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens
        
        if applications.isEmpty && categories.isEmpty && webDomains.isEmpty {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
        } else {
            store.shield.applications = applications
            store.shield.applicationCategories = .specific(categories)
            store.shield.webDomains = webDomains
        }
    }
    
    public static func clearShields() {
        ManagedSettingsStore().clearAllSettings()
    }
}
