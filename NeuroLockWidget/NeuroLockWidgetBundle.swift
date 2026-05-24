//
//  NeuroLockWidgetBundle.swift
//  NeuroLockWidget
//
//  Created by Rahul Chauhan on 4/15/26.
//

import WidgetKit
import SwiftUI

@main
struct NeuroLockWidgetBundle: WidgetBundle {
    var body: some Widget {
        NeuroLockWidget()
        NeuroLockWidgetControl()
        NeuroLockWidgetLiveActivity()
    }
}
