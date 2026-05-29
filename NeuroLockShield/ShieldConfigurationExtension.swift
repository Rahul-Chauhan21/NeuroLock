//
//  ShieldConfigurationExtension.swift
//  NeuroLockShield
//
//  Created by Rahul Chauhan on 4/15/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return handleShieldState()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return handleShieldState()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return handleShieldState()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return handleShieldState()
    }
    
    private func handleShieldState() -> ShieldConfiguration {
        // FIX FOR SIMULATOR AND DEVICE RACE CONDITIONS:
        if FocusShared.isBypassActive() {
            // Return a completely transparent shield.
            // This prevents the OS from tearing down the app process.
            return ShieldConfiguration(
                backgroundBlurStyle: .none,
                backgroundColor: .clear,
                icon: nil,
                title: nil,
                subtitle: nil,
                primaryButtonLabel: nil,
                secondaryButtonLabel: nil
            )
        }
        
        return createEscalatedConfiguration()
    }
    
    private func createEscalatedConfiguration() -> ShieldConfiguration {
        let level = FocusShared.getEscalationLevel()
        
        var title = "Impulse Check"
        var subtitle = "Is this a conscious choice, or just muscle memory?"
        var primaryButtonLabel = "I'm choosing this (15m)"
        var primaryButtonColor: UIColor = .systemBlue
        
        if level == 1 {
            title = "The Dopamine Trap"
            subtitle = "You've bypassed this once already. Is this app more important than your focus goal?"
            primaryButtonLabel = "I'm breaking my focus."
            primaryButtonColor = .systemOrange
        } else if level >= 2 {
            title = "Autopilot Detected"
            subtitle = "Your impulsive brain is in control. Manual override required in NeuroLock."
            primaryButtonLabel = "Prove I'm in charge"
            primaryButtonColor = .systemRed
        }
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: .systemBackground.withAlphaComponent(0.8),
            icon: UIImage(systemName: "lock.shield"),
            title: ShieldConfiguration.Label(text: title, color: .label),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: primaryButtonLabel, color: .white),
            primaryButtonBackgroundColor: primaryButtonColor,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Dismiss", color: .systemBlue)
        )
    }
}
