//
//  ShieldActionExtension.swift
//  NeuroLockAction
//
//  Created by Rahul Chauhan on 4/15/26.
//

import ManagedSettings
import Foundation

class ShieldActionExtension: ShieldActionDelegate {
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    private func handleAction(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            let currentLevel = FocusShared.getEscalationLevel()
            
            if currentLevel < 2 {
                // Increment escalation and allow bypass (15-minute default)
                FocusShared.setEscalationLevel(currentLevel + 1)
                completionHandler(.none)
            } else {
                // At Level 3 (level >= 2), don't allow bypass.
                // The user must open the main app and do the protocol.
                // We return .defer to keep the shield active.
                completionHandler(.defer)
            }
        case .secondaryButtonPressed:
            // Dismiss (close the blocked app)
            completionHandler(.close)
        default:
            completionHandler(.close)
        }
    }
}
