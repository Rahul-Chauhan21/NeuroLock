//
//  ToggleFocusIntent.swift
//  NeuroLockWidget
//
//  Created by Rahul Chauhan on 4/15/26.
//

import AppIntents
import ManagedSettings
import FamilyControls
import Foundation
import WidgetKit

struct ToggleFocusIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Focus"
    static var description: IntentDescription = "Starts or stops your NeuroLock focus session."
    
    func perform() async throws -> some IntentResult {
        let isActive = FocusShared.getIsSessionActive()
        
        if isActive {
            // Stop session
            FocusShared.setIsSessionActive(false)
            FocusShared.setEscalationLevel(0)
            FocusShared.clearShields()
        } else {
            // Start session
            FocusShared.setIsSessionActive(true)
            FocusShared.setEscalationLevel(0) // Reset level
            
            // Apply shields from shared selection
            let selection = FocusShared.loadSelection()
            FocusShared.applyShields(selection: selection)
        }
        
        return .result()
    }
}
