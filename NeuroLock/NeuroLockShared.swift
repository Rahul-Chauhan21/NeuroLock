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
    public static let blockedAppsKey = "blockedApplicationsKey"
    public static let bypassActiveKey = "isBypassActive"
    public static let bypassUntilKey = "bypassUntil"
    
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
    
    // Example implementation methods inside your shared file:
    public static func isBypassActive() -> Bool {
        guard sharedDefaults?.bool(forKey: bypassActiveKey) == true else {
            return false
        }
        
        guard let bypassUntil = getBypassUntil() else {
            return true
        }
        
        return bypassUntil > Date()
    }

    public static func setBypassActive(_ active: Bool) {
        sharedDefaults?.set(active, forKey: bypassActiveKey)
        sharedDefaults?.synchronize() // Force synchronization instantly across extensions
    }
    
    public static func getBypassUntil() -> Date? {
        sharedDefaults?.object(forKey: bypassUntilKey) as? Date
    }
    
    public static func beginBypass(until date: Date) {
        sharedDefaults?.set(true, forKey: bypassActiveKey)
        sharedDefaults?.set(date, forKey: bypassUntilKey)
        sharedDefaults?.synchronize()
    }
    
    public static func endBypass() {
        sharedDefaults?.set(false, forKey: bypassActiveKey)
        sharedDefaults?.removeObject(forKey: bypassUntilKey)
        sharedDefaults?.synchronize()
    }

    // Call this in your main app when the user selects apps to block
    public static func saveBlockedApplications(_ tokens: Set<ApplicationToken>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tokens) {
            sharedDefaults?.set(encoded, forKey: blockedAppsKey)
        }
    }
    
    public static func getBlockedApplicationTokens() -> Set<ApplicationToken> {
        guard let data = sharedDefaults?.data(forKey: blockedAppsKey) else {
            return []
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode(Set<ApplicationToken>.self, from: data)) ?? []
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
            saveBlockedApplications(selection.applicationTokens)
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
    
    public static func applySavedShields() {
        guard getIsSessionActive() else {
            clearShields()
            return
        }
        
        applyShields(selection: loadSelection())
    }
    
    public static func clearShields() {
        ManagedSettingsStore().clearAllSettings()
    }
}
