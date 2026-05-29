//
//  ShieldActionExtension.swift
//  NeuroLockAction
//
//  Created by Rahul Chauhan on 4/15/26.
//

import Foundation
import ManagedSettings
import DeviceActivity

class ShieldActionExtension: ShieldActionDelegate {
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleUniversalAction(action: action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleUniversalAction(action: action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleUniversalAction(action: action, completionHandler: completionHandler)
    }

    private func handleUniversalAction(
        action: ShieldAction,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            let currentLevel = FocusShared.getEscalationLevel()
            
            if currentLevel < 2 {
                do {
                    let bypassUntil = Date().addingTimeInterval(15 * 60)
                    try startBypassTimer(until: bypassUntil)
                    
                    FocusShared.setEscalationLevel(currentLevel + 1)
                    FocusShared.beginBypass(until: bypassUntil)
                    FocusShared.clearShields()
                    
                    completionHandler(.close)
                } catch {
                    FocusShared.endBypass()
                    FocusShared.applySavedShields()
                    completionHandler(.defer)
                }
            } else {
                completionHandler(.defer)
            }
            
        case .secondaryButtonPressed:
            completionHandler(.close)
            
        default:
            completionHandler(.close)
        }
    }

    private func startBypassTimer(until intervalEnd: Date) throws {
        let center = DeviceActivityCenter()
        let now = Date()
        let calendar = Calendar.current
        
        let schedule = DeviceActivitySchedule(
            intervalStart: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now),
            intervalEnd: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: intervalEnd),
            repeats: false
        )
        
        center.stopMonitoring([.temporaryBypass])
        try center.startMonitoring(.temporaryBypass, during: schedule)
    }
}

extension DeviceActivityName {
    static let temporaryBypass = DeviceActivityName("temporaryBypass")
}
