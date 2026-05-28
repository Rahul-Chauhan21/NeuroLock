//
//  NeuroLockTests.swift
//  NeuroLockTests
//
//  Created by Rahul Chauhan on 4/15/26.
//

import Testing
import Foundation
@testable import NeuroLock

@Suite(.serialized)
@MainActor
struct NeuroLockTests {

    @Test("Test FocusShared state storage for Escalation Levels")
    func testEscalationLevelStorage() async throws {
        // Reset to initial state
        FocusShared.setEscalationLevel(0)
        #expect(FocusShared.getEscalationLevel() == 0)
        
        // Update level and check
        FocusShared.setEscalationLevel(1)
        #expect(FocusShared.getEscalationLevel() == 1)
        
        FocusShared.setEscalationLevel(2)
        #expect(FocusShared.getEscalationLevel() == 2)
        
        // Clean up
        FocusShared.setEscalationLevel(0)
    }

    @Test("Test FocusShared state storage for Session Active status")
    func testSessionActiveStorage() async throws {
        // Reset to initial state
        FocusShared.setIsSessionActive(false)
        #expect(FocusShared.getIsSessionActive() == false)
        
        // Update session state
        FocusShared.setIsSessionActive(true)
        #expect(FocusShared.getIsSessionActive() == true)
        
        // Clean up
        FocusShared.setIsSessionActive(false)
    }

    @Test("Test DeviceActivityManager session lifecycle states")
    func testDeviceActivityManagerSessionLifecycle() async throws {
        let manager = DeviceActivityManager.shared
        
        // 1. Initial State verification (depends on Screen Time permissions, let's verify logic is responsive)
        let originalSessionState = manager.isSessionActive
        
        // 2. Start Focus Session verification
        manager.startFocusSession()
        #expect(manager.isSessionActive == true)
        #expect(manager.escalationLevel == 0)
        
        // 3. Stop Focus Session verification
        manager.stopFocusSession()
        #expect(manager.isSessionActive == false)
        #expect(manager.escalationLevel == 0)
        
        // Reset to original state to prevent side effects in other modules
        manager.isSessionActive = originalSessionState
    }
}
