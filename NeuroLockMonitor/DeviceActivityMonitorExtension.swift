//
//  DeviceActivityMonitorExtension.swift
//  NeuroLockMonitor
//
//  Created by Rahul Chauhan on 4/15/26.
//

import DeviceActivity

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        guard activity == .temporaryBypass else {
            return
        }
        
        FocusShared.endBypass()
        FocusShared.setEscalationLevel(0)
        FocusShared.applySavedShields()
    }
}

extension DeviceActivityName {
    static let temporaryBypass = DeviceActivityName("temporaryBypass")
}
